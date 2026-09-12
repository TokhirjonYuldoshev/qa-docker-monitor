# Правила внесения изменений

Этот репозиторий рассматривает PostgreSQL health как **наблюдаемый контракт**, а не как декоративный зелёный workflow. Любое изменение должно сохранять достоверность сигнала и оставаться понятным для review.

## Основной health-контракт

Успешный monitoring run должен доказать два факта:

1. PostgreSQL принимает запись;
2. marker, созданный **текущим запуском**, читается обратно без подмены чужими данными.

Доставка уведомления вторична и никогда не должна переписывать database-health result.

Плановый GitHub Actions path — это **synthetic canary на временном PostgreSQL service container**. Он проверяет monitoring contract и workflow implementation, но не является доказательством доступности внешней production/long-lived БД. Отдельный Windows/Jenkins-compatible path работает в другой environment boundary. Подробнее: [`docs/monitoring-boundary.md`](docs/monitoring-boundary.md).

## Политика изменений

- Один Pull Request — одна сфокусированная инженерная задача.
- Нельзя превращать реальный PostgreSQL failure в green за счёт подавления exit code.
- Telegram availability не является частью database-health truth signal.
- Нельзя заменять exact per-run read-back на проверку глобально последней строки.
- Не добавляйте произвольные `sleep`, rerun loops или retries для маскировки readiness/infrastructure проблем.
- Secrets не хранятся в репозитории. Bot token, chat ID и другие credentials должны приходить из GitHub/Jenkins secret stores.
- Сохраняйте явную семантику `ON_ERROR_STOP=1` для PostgreSQL-команд, влияющих на health result.
- Scheduled synthetic monitoring должен оставаться лёгким и детерминированным.
- В документации и incident analysis явно разделяйте synthetic и separately managed environments.
- Если меняются monitoring contract, schedule или failure semantics, одновременно обновляйте связанную документацию.

## Локальная проверка Windows contract

Изменения `monitor.bat` до merge должны пройти repository-native regression harness:

```powershell
pwsh -NoProfile -File ./tests/monitor-contract.ps1
```

Harness должен подтвердить:

1. DB write/read success + Telegram disabled → exit `0`;
2. DB write/read success + Telegram failure → exit `0`;
3. persisted read-back mismatch → exit `1`;
4. DB command failure остаётся exit `1`, даже если notification delivery тоже упала;
5. read-back query обращается к exact marker текущего запуска.

Harness намеренно не требует реальной БД или Telegram. Он защищает orchestration/failure semantics, но **не заменяет** operational PostgreSQL health check.

## Что проверять при изменении workflow

Минимальный набор:

1. YAML syntax и trigger scope корректны;
2. PostgreSQL service health check остаётся включён;
3. write/read verification падает при SQL error или неправильном persisted marker;
4. scheduled run намеренно пропускает Windows contract;
5. `CI / Required gate` не может стать green при падении обязательного upstream signal;
6. cleanup не переписывает exit status health check;
7. Telegram остаётся best-effort observability;
8. в PR нет secrets и временных локальных файлов.

Для `monitor.bat` сохраняется та же ownership model: database health владеет exit code, Telegram и retention cleanup остаются вспомогательными операциями.

## Evidence для Pull Request

PR готов к merge, когда:

1. понятны техническая цель и owning signal;
2. `PostgreSQL write/read health check` — green;
3. `Windows monitor contract` — green для non-scheduled validation;
4. `CI / Required gate` — green;
5. изменения `monitor.bat` проходят `tests/monitor-contract.ps1`;
6. изменения health semantics явно указывают, какая команда/assertion остаётся source of truth;
7. environment claims согласованы с `docs/monitoring-boundary.md`;
8. ни один quality signal не был ослаблен ради зелёного результата.

При подозрении на runner/platform incident используйте [`docs/incident-runbook.md`](docs/incident-runbook.md). Targeted diagnostic rerun допустим только после конкретного evidence внешнего failure и восстановления. Стратегия rerun-until-green не принимается.

Зелёный CI доказывает прохождение проверенного path на конкретной revision. Он не доказывает, что PostgreSQL, GitHub runner или Telegram никогда не могут упасть вне окна этого запуска.
