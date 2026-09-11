# Windows monitor contract harness

`monitor-contract.ps1` is the executable contract for the local/Jenkins-compatible `monitor.bat` path.

It validates orchestration and failure semantics without requiring a live PostgreSQL container, Jenkins agent or Telegram credentials. The harness creates isolated command doubles for `docker.cmd` and `curl.cmd`, prepends them only for the test process, executes the production batch script and removes all temporary state in `finally` cleanup.

## Covered scenarios

| Scenario | Expected result |
| --- | ---: |
| Persisted DB write/read succeeds, Telegram disabled | exit `0` |
| Persisted DB write/read succeeds, Telegram delivery fails | exit `0` |
| Read-back does not match the current run marker | exit `1` |
| DB command fails and Telegram delivery also fails | exit `1` |

The harness also inspects the captured Docker command log and proves that the production monitor queries the exact per-run marker rather than trusting a global/latest database row.

## Run locally

Requirements:

- Windows;
- PowerShell 7+ (`pwsh`);
- `cmd.exe`.

From the repository root:

```powershell
pwsh -NoProfile -File ./tests/monitor-contract.ps1
```

A healthy run ends with:

```text
Windows monitor contract: all scenarios passed.
```

## CI ownership

`.github/workflows/main.yml` executes the same repository-native script in the `Windows monitor contract` job for pull requests, pushes to `main` and manual runs. Scheduled operational PostgreSQL checks intentionally skip the Windows contract to avoid spending a Windows runner when no code change is being validated.

The script is a regression contract, not a substitute for the real PostgreSQL write/read health path. The operational source of truth remains the persisted database health result.
