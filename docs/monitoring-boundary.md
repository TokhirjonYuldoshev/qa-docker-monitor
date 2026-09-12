# Границы мониторинга

## Что представляет собой scheduled GitHub Actions check

Плановый workflow — это **synthetic PostgreSQL write/read canary**. Каждый запуск поднимает изолированный PostgreSQL 16 service container, ждёт readiness, записывает уникальный marker и проверяет, что этот же marker читается обратно.

Такой path доказывает, что monitoring contract и SQL health logic репозитория работают против реального PostgreSQL instance в GitHub-hosted runner environment.

## Чего этот check не доказывает

Scheduled GitHub Actions path **не мониторит** customer, production или long-lived external PostgreSQL database. База временная и принадлежит конкретному workflow run.

Поэтому green scheduled run означает:

- PostgreSQL стал ready внутри runner environment;
- health-check implementation смог создать, записать и прочитать state;
- aggregate monitoring gate корректно оценил сигнал.

Он **не доказывает** доступность независимой persistent environment.

## Path для отдельно управляемой среды

`monitor.bat` представляет Windows/Jenkins-compatible path для отдельно управляемого PostgreSQL container. Он использует exact per-run marker и сохраняет database-health exit semantics независимо от Telegram delivery.

Репозиторий намеренно разделяет эти области:

| Path | Основная цель | Время жизни данных |
| --- | --- | --- |
| GitHub Actions scheduled check | Synthetic canary и validation monitoring logic | Ephemeral, один workflow run |
| Pull Request GitHub Actions check | Pre-merge regression protection | Ephemeral, один workflow run |
| Windows/Jenkins-compatible monitor | Health contract для separately managed container | Внешнее по отношению к скрипту |
| Telegram | Доставка результата / observability | Не является health source of truth |

## Правила обработки ошибок

- PostgreSQL readiness, write или exact read-back failure — настоящий failed health signal для выполняемого path.
- Telegram transport failure не превращает healthy database signal в red и не скрывает database failure.
- Aggregate gate может объединять validation signals, но не заменяет их собственное evidence.
- Rerun-until-green loops, произвольные sleeps и retries, скрывающие failures, не входят в monitoring strategy.

Эта граница описана явно, чтобы портфолио показывало корректную observability engineering практику и не выдавало synthetic check за production monitoring чужой системы.
