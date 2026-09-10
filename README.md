# Гибридный QA-мониторинг PostgreSQL

[![QA Database Health Monitor](https://github.com/TokhirjonYuldoshev/qa-docker-monitor/actions/workflows/main.yml/badge.svg)](https://github.com/TokhirjonYuldoshev/qa-docker-monitor/actions/workflows/main.yml)

Portfolio-проект по инженерному мониторингу качества: PostgreSQL проверяется через **реальную запись с последующим read-back**, orchestration валидируется в **GitHub Actions**, Windows/Jenkins-логика защищена contract-тестами, а operational results отправляются в **Telegram**.

## Что демонстрирует проект

- scheduled PostgreSQL health checks в GitHub Actions;
- pre-merge validation изменений monitoring logic через Pull Request;
- PostgreSQL 16 service container с readiness health check;
- реальный SQL `CREATE / INSERT / SELECT` вместо поверхностной проверки порта;
- уникальный marker на каждый workflow run и явную read-back assertion;
- разделение **database health signal** и **notification transport**;
- contract-тесты Windows/Jenkins monitor через изолированные command doubles;
- стабильный агрегирующий `CI / Required gate`;
- структурированный GitHub Actions Summary;
- Telegram observability с прямой ссылкой на run;
- manual-only Telegram diagnostics: `getMe` → `getChat` → `sendMessage`;
- controlled Dependabot maintenance;
- security/QA governance через `SECURITY.md` и PR template.

## Архитектура

```mermaid
flowchart LR
    GH[GitHub Actions] --> PG1[PostgreSQL 16 service]
    GH --> SQL1[CREATE + INSERT + SELECT]
    SQL1 --> R[Persisted DB health result]

    GH --> WT[Windows contract tests]
    WT --> BAT[monitor.bat]
    J[Jenkins / Windows] --> BAT
    BAT --> PG2[Persistent Docker PostgreSQL]

    R --> G[CI / Required gate]
    WT --> G
    G --> S[GitHub Actions Summary]
    G -. result .-> TG[Telegram notification]
```

## Основной workflow

Файл: `.github/workflows/main.yml`.

Триггеры:

- Pull Request — проверяет SQL health и Windows contract до merge, Telegram намеренно не используется;
- push в `main` — выполняет обе validation paths и отправляет итог в Telegram;
- ручной `workflow_dispatch` — полный on-demand запуск;
- schedule в **09:00 и 21:00 UTC** — operational PostgreSQL health check без лишнего расхода Windows runner.

Linux job поднимает PostgreSQL 16, ждёт readiness и выполняет write/read-проверку. На каждый workflow run формируется уникальный marker из `GITHUB_RUN_ID` и `GITHUB_RUN_ATTEMPT`:

```sql
CREATE TABLE IF NOT EXISTS robot_log (...);
INSERT INTO robot_log (status) VALUES ('<unique run marker>');
SELECT count(*) FROM robot_log WHERE status = '<unique run marker>';
```

Health считается успешным только если SQL-команды завершились без ошибки и read-back вернул **ровно одну** сохранённую запись. Таким образом, проверяется не только принятие `INSERT`, но и наблюдаемое persisted state.

## Windows/Jenkins contract

`windows-latest` job запускает `monitor.bat` против изолированных doubles для `docker.cmd` и `curl.cmd` и проверяет failure semantics без реальной БД, Jenkins agent или Telegram credentials.

| Сценарий | Ожидаемый exit code |
| --- | ---: |
| DB успешна, Telegram выключен | `0` |
| DB успешна, Telegram transport упал | `0` |
| DB упала и Telegram тоже упал | `1` |

Контракт защищает два ключевых правила:

- ошибка Telegram не должна превращать исправную БД в ложный failure;
- ошибка БД не должна теряться из-за notification logic.

## Aggregate gate

`CI / Required gate` собирает результаты независимых jobs:

- `PostgreSQL write health check`;
- `Windows monitor contract`.

Для PR/push/manual нужны оба успешных сигнала. Для scheduled run Windows contract намеренно `skipped`, а gate оценивает operational PostgreSQL health.

GitHub Actions Summary показывает общий итог, trigger, branch, commit и прямую ссылку на run.

## Telegram observability

Telegram вынесен в отдельный job после quality gate. Сообщение содержит:

- общий статус `HEALTHY` / `ALERT`;
- PostgreSQL write/read health;
- Windows monitor contract;
- `CI / Required gate`;
- репозиторий, ветку, автора, trigger и commit;
- прямую ссылку на GitHub Actions run.

Поддерживаются repository secrets:

```text
TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID
```

Для обратной совместимости также принимаются:

```text
TG_TOKEN
TG_CHAT_ID
```

Notification transport — **вспомогательный observability signal**. Если Telegram API недоступен, реальный DB health result сохраняется и не подменяется transport failure.

Для отдельной проверки интеграции используется manual-only workflow `.github/workflows/telegram-test.yml`. Он проверяет bot token, target chat и отправку тестового сообщения, чтобы отличать ошибку Telegram-конфигурации от ошибки PostgreSQL.

## Локальный / Jenkins-compatible monitor

`monitor.bat` выполняет `INSERT` в PostgreSQL внутри Docker container и возвращает ненулевой exit code при реальном DB failure.

Runtime configuration:

| Переменная | Обязательна | Поведение |
| --- | --- | --- |
| `DB_CONTAINER` | Нет | по умолчанию `dev-postgres-db` |
| `BUILD_NUMBER` | Нет | вне Jenkins используется `manual` |
| `TOKEN` | Нет для DB health | вместе с `CHAT_ID` включает Telegram |
| `CHAT_ID` | Нет для DB health | вместе с `TOKEN` включает Telegram |

Telegram delivery и retention cleanup выполняются best-effort и не имеют права переписать database-health exit code.

## Failure semantics

- readiness/setup/SQL failure делает health path красным;
- persisted PostgreSQL write/read result является главным cloud-сигналом;
- уникальный run marker исключает ложноположительный read-back по данным другого запуска;
- Telegram failure не создаёт ложный DB failure;
- notification failure не скрывает реальную ошибку БД;
- PR validation не отправляет operational Telegram alerts;
- aggregate gate не может стать зелёным, если обязательный validation job упал;
- Windows contract защищает эти правила от регрессии.

## Dependency maintenance

`.github/dependabot.yml` проверяет GitHub Actions раз в неделю по часовому поясу `Europe/Minsk`.

Minor/patch updates группируются, major updates остаются отдельными инженерными изменениями. Любой dependency PR проходит те же PostgreSQL, Windows contract и aggregate gates до merge.

## Стек

| Область | Технология |
| --- | --- |
| CI / schedule | GitHub Actions |
| Local automation | Jenkins / Windows batch |
| Database | PostgreSQL 16 |
| Containerization | Docker |
| Contract validation | Windows runner + command doubles |
| Health validation | SQL write + read-back assertion |
| Merge signal | `CI / Required gate` |
| Notifications | Telegram Bot API |
| Dependency maintenance | Dependabot |

## Структура репозитория

```text
qa-docker-monitor/
├── .github/
│   ├── dependabot.yml
│   ├── pull_request_template.md
│   └── workflows/
│       ├── main.yml
│       └── telegram-test.yml
├── SECURITY.md
├── monitor.bat
└── README.md
```

## Почему это QA-проект

Задача проекта — не просто проверить, что процесс PostgreSQL запущен. Монитор проверяет наблюдаемую способность критичной зависимости **принять запись и вернуть её обратно**, формирует детерминированный CI signal, валидирует orchestration contract до merge и отделяет dependency health от alert-delivery health.

Такой подход ближе к инженерии качества production-систем, чем обычный `ping` или port check.

---

**Portfolio project by Tokhirjon Yuldoshev**
