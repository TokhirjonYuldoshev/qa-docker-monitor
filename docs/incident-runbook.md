# Runbook по инцидентам мониторинга

Этот документ задаёт порядок разбора сбоев `QA Database Health Monitor`, не сводя независимые сигналы к общей фразе «CI упал».

## Владельцы сигналов

| Сигнал | Source of truth | Блокирует | Первое действие |
| --- | --- | --- | --- |
| PostgreSQL write/read health | job `database-health` | Да | Сначала проверить SQL/read-back failure, не Telegram |
| Windows monitor contract | job `windows-contract` | Да для PR/push/manual | Найти regression конкретного exit-code scenario |
| Aggregate gate | `CI / Required gate` | Да | Определить, какой обязательный upstream signal неуспешен |
| Telegram delivery | job `notify` / Telegram diagnostic | Нет | Считать transport-проблемой, если DB health зелёный |

## Порядок triage

1. **Откройте aggregate summary.** Определите, падает PostgreSQL health, Windows contract или оба сигнала.
2. **Перейдите в первый failing source job**, а не в notification job. Именно source job владеет quality signal.
3. **Классифицируйте причину:** database health, contract regression, infrastructure/runner problem или notification transport.
4. **Соберите evidence:** trigger, branch, commit, run ID, failing step, точную команду и результат.
5. **Воспроизводите минимальный failing path.** Не добавляйте retry, sleep или suppression уведомлений ради зелёного workflow.
6. **Исправьте owning layer** и прогоните обычный PR gate до merge.

## Ошибка PostgreSQL health

Красный `PostgreSQL write/read health check` означает, что workflow не смог доказать persisted database state.

Проверяйте по порядку:

- service readiness и старт container;
- `psql` connectivity/authentication;
- результат `CREATE TABLE`;
- результат `INSERT`;
- exact read-back count для marker текущего запуска;
- runner/network/platform evidence, если service не стал usable.

Инвариант:

```text
CREATE succeeds -> INSERT succeeds -> SELECT returns exactly one row for this run marker
```

Успешный port check или process status **не является** достаточным evidence здоровья БД.

## Ошибка Windows contract

Windows job проверяет failure semantics `monitor.bat` через изолированные command doubles. Его failure означает regression orchestration logic, а не доказательство проблем реальной PostgreSQL.

| Сценарий | Ожидаемый exit |
| --- | ---: |
| DB write/read success, Telegram disabled | `0` |
| DB write/read success, Telegram failure | `0` |
| DB read-back mismatch | `1` |
| DB command failure + Telegram failure | `1` |

Если scenario падает, сначала анализируйте exit-code path batch-скрипта. Telegram success не должен быть условием database health.

## Только Telegram failure

Если required gate зелёный, а notification delivery упал:

- monitoring run остаётся **healthy**;
- manual Telegram diagnostic workflow используется для разделения missing secrets, invalid bot token, invalid chat target и API transport failure;
- database-health semantics не меняются ради обхода notification outage.

## Runner/platform incident

Признаки внешней CI/platform проблемы: failure до выполнения project logic, package/service provisioning failure, unrelated runner/network errors.

В таком случае:

- сохраните исходный failed run;
- подтвердите, что тот же commit/configuration не менял падающую project logic;
- допускается максимум один targeted diagnostic rerun после конкретного evidence восстановления внешнего условия;
- не добавляйте постоянные retries или sleeps для скрытия инцидента.

## Модель severity

| Severity | Пример | Реакция |
| --- | --- | --- |
| SEV-1 | Повторяющийся scheduled DB health failure с подтверждённой write/read ошибкой | Немедленный разбор как service-health incident |
| SEV-2 | Regression обязательного contract/gate на `main` | Остановить дальнейшие изменения до восстановления сигнала |
| SEV-3 | Telegram недоступен при зелёном required health gate | Исправить observability transport; DB health остаётся валидным |
| SEV-4 | Проблема документации или Summary presentation | Обычный PR flow |

## Критерии закрытия

Инцидент закрывается только когда:

- owning signal проходит на исправленной revision;
- `CI / Required gate` правильно отражает upstream results;
- не добавлен retry/sleep workaround, маскирующий root cause;
- документация обновлена, если инцидент выявил отсутствующее operational rule.

## Запрещённые практики

Нельзя:

- считать Telegram source of truth для PostgreSQL health;
- понижать реальный SQL/read-back failure до warning;
- добавлять произвольные задержки ради исчезновения timing failure;
- мержить monitoring-logic change при красной обязательной validation;
- многократно перезапускать один и тот же revision до случайного green.
