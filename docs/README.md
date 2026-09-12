# Карта документации

Эта папка содержит operational и architectural документацию проекта. Основной язык — русский; технические имена jobs, файлов, команд, переменных и quality signals сохраняются без перевода, чтобы документация точно совпадала с CI и кодом.

## Документы

| Документ | Назначение |
| --- | --- |
| [`monitoring-boundary.md`](monitoring-boundary.md) | Границы synthetic GitHub Actions monitoring и separately managed Windows/Jenkins path |
| [`incident-runbook.md`](incident-runbook.md) | Порядок triage, signal ownership, severity и критерии закрытия инцидента |
| [`../tests/README.md`](../tests/README.md) | Как работает и запускается Windows contract harness |
| [`../CONTRIBUTING.md`](../CONTRIBUTING.md) | Change policy и evidence, необходимые перед merge |
| [`../SECURITY.md`](../SECURITY.md) | Secrets, security findings и правила PostgreSQL image security |

## Быстрая навигация по задаче

- Нужно понять, **что именно мониторит проект** → `monitoring-boundary.md`.
- Упал CI или scheduled health check → `incident-runbook.md`.
- Меняется `monitor.bat` → `tests/README.md` + `CONTRIBUTING.md`.
- Есть credential/security concern → `SECURITY.md`.
- Готовится Pull Request → `CONTRIBUTING.md` и `.github/pull_request_template.md`.

Главный обзор архитектуры, CI, Telegram и структуры репозитория находится в корневом [`README.md`](../README.md).
