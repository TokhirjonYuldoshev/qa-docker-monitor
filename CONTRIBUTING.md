# Contributing

This repository treats PostgreSQL health as an observable contract rather than a cosmetic workflow result. Changes should preserve that signal and remain easy to review.

## Core health contract

A healthy monitoring run must prove that PostgreSQL can accept a write and that the expected row can be observed. Notification delivery is secondary and must never overwrite the database-health result.

## Change policy

- Keep one focused concern per pull request.
- Do not turn a real PostgreSQL failure green by suppressing exit codes.
- Do not make Telegram availability part of the database-health truth signal.
- Avoid arbitrary sleeps or retries that hide readiness problems.
- Keep secrets out of the repository. Bot tokens, chat IDs and other credentials must come from GitHub/Jenkins secret stores.
- Preserve explicit `ON_ERROR_STOP=1` semantics for PostgreSQL commands that define the health result.
- Keep scheduled monitoring lightweight and deterministic.
- Update README documentation when the monitoring contract, schedule or failure semantics change.

## Validation expectations

For workflow changes, verify at minimum:

1. YAML syntax and trigger scope are correct;
2. PostgreSQL service health checks remain enabled;
3. the write/read verification fails on SQL errors;
4. cleanup cannot replace the health-check exit status;
5. Telegram notification remains best-effort observability;
6. no secrets or transient local files are introduced.

For `monitor.bat`, preserve the same semantics as the GitHub Actions path: database failure exits non-zero, database success exits zero, and Telegram/retention cleanup do not rewrite that result.

## Pull request evidence

A pull request is merge-ready when the technical intent is clear and the relevant GitHub Actions run is green. For changes that alter health semantics, include a short explanation of which command or assertion remains the source of truth.

Green CI is evidence that the checked path passed; it is not proof that the live database or Telegram service can never fail outside the run window.
