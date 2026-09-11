# Contributing

This repository treats PostgreSQL health as an observable contract rather than a cosmetic workflow result. Changes should preserve that signal and remain easy to review.

## Core health contract

A healthy monitoring run must prove that PostgreSQL can accept a write and that the marker created by the **current run** can be read back exactly. Notification delivery is secondary and must never overwrite the database-health result.

## Change policy

- Keep one focused concern per pull request.
- Do not turn a real PostgreSQL failure green by suppressing exit codes.
- Do not make Telegram availability part of the database-health truth signal.
- Do not replace exact per-run read-back with a global latest-row assertion.
- Avoid arbitrary sleeps, rerun loops or retries that hide readiness/infrastructure problems.
- Keep secrets out of the repository. Bot tokens, chat IDs and other credentials must come from GitHub/Jenkins secret stores.
- Preserve explicit `ON_ERROR_STOP=1` semantics for PostgreSQL commands that define the health result.
- Keep scheduled monitoring lightweight and deterministic.
- Update the relevant documentation when the monitoring contract, schedule or failure semantics change.

## Local Windows contract validation

Changes to `monitor.bat` must run the repository-native regression harness before merge:

```powershell
pwsh -NoProfile -File ./tests/monitor-contract.ps1
```

The harness uses isolated command doubles and must prove all of the following:

1. DB write/read success with Telegram disabled exits `0`;
2. DB write/read success with Telegram failure still exits `0`;
3. a persisted read-back mismatch exits `1`;
4. a DB command failure remains exit `1` even when notification delivery also fails;
5. the read-back query targets the exact marker for the current run.

The harness is intentionally independent of a real database or Telegram service. It protects orchestration/failure semantics; it does **not** replace the operational PostgreSQL health check.

## Workflow validation expectations

For workflow changes, verify at minimum:

1. YAML syntax and trigger scope are correct;
2. PostgreSQL service health checks remain enabled;
3. the write/read verification fails on SQL errors or a wrong persisted marker;
4. scheduled runs keep the Windows contract intentionally skipped;
5. `CI / Required gate` cannot become green when a required upstream signal fails;
6. cleanup cannot replace the health-check exit status;
7. Telegram notification remains best-effort observability;
8. no secrets or transient local files are introduced.

For `monitor.bat`, preserve the same ownership model as the GitHub Actions path: database health owns the exit code, while Telegram and retention cleanup remain auxiliary operations.

## Pull request evidence

A pull request is merge-ready when:

1. the technical intent and owning signal are clear;
2. `PostgreSQL write/read health check` is green;
3. `Windows monitor contract` is green for non-scheduled validation;
4. `CI / Required gate` is green;
5. changes to `monitor.bat` pass `tests/monitor-contract.ps1`;
6. health-semantics changes explain which command/assertion remains the source of truth;
7. no quality signal was weakened to obtain a green result.

For suspected runner/platform incidents, follow `docs/incident-runbook.md`. A targeted diagnostic rerun is justified only after concrete evidence of an external failure and recovery; rerun-until-green is not an accepted validation strategy.

Green CI proves that the checked path passed at that revision. It is not proof that the live database, GitHub runner or Telegram service can never fail outside the run window.
