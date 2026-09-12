# Windows contract harness для monitor.bat

`monitor-contract.ps1` — исполняемый regression contract для локального/Jenkins-compatible path `monitor.bat`.

Он проверяет orchestration и failure semantics без реального PostgreSQL container, Jenkins agent или Telegram credentials. Harness создаёт изолированные command doubles для `docker.cmd` и `curl.cmd`, добавляет их в `PATH` только тестового процесса, запускает production batch script и удаляет временное состояние в `finally` cleanup.

## Покрываемые сценарии

| Сценарий | Ожидаемый результат |
| --- | ---: |
| Persisted DB write/read успешен, Telegram отключён | exit `0` |
| Persisted DB write/read успешен, Telegram delivery упал | exit `0` |
| Read-back не совпал с marker текущего запуска | exit `1` |
| DB command упала и Telegram delivery тоже упала | exit `1` |

Harness также анализирует captured Docker command log и доказывает, что production monitor запрашивает **exact per-run marker**, а не доверяет глобально последней строке БД.

## Локальный запуск

Требования:

- Windows;
- PowerShell 7+ (`pwsh`);
- `cmd.exe`.

Из корня репозитория:

```powershell
pwsh -NoProfile -File ./tests/monitor-contract.ps1
```

Успешный запуск заканчивается сообщением:

```text
Windows monitor contract: all scenarios passed.
```

## Роль в CI

`.github/workflows/main.yml` запускает тот же repository-native script в job `Windows monitor contract` для Pull Request, push в `main` и manual run. Scheduled synthetic PostgreSQL checks намеренно пропускают Windows contract, чтобы не расходовать Windows runner без изменения кода.

Этот script — regression contract, а не замена реального PostgreSQL write/read health path. Operational source of truth остаётся persisted database health result.
