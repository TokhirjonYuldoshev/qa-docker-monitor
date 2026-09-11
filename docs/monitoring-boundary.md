# Monitoring boundary

## What the scheduled GitHub Actions check is

The scheduled workflow is a **synthetic PostgreSQL write/read canary**. Each run starts an isolated PostgreSQL 16 service container, waits for readiness, writes a unique marker and verifies that the same marker can be read back.

This path proves that the repository's monitoring contract and SQL health logic work against a real PostgreSQL instance under the GitHub-hosted runner environment.

## What it is not

The scheduled GitHub Actions path does **not** monitor a customer, production or long-lived external PostgreSQL database. Its database is ephemeral and belongs to the workflow run.

Accordingly, a green scheduled run means:

- PostgreSQL became ready in the runner environment;
- the health-check implementation could create/write/read state;
- the aggregate monitoring gate evaluated the signal correctly.

It does not prove the availability of an unrelated persistent environment.

## Persistent-environment path

`monitor.bat` represents the Jenkins/Windows-compatible path for a separately managed PostgreSQL container. It uses an exact per-run marker and preserves database-health exit semantics independently from Telegram delivery.

The repository contract intentionally keeps these concerns distinct:

| Path | Primary purpose | Data lifetime |
| --- | --- | --- |
| GitHub Actions scheduled check | Synthetic canary and monitoring-logic validation | Ephemeral per workflow run |
| Pull-request GitHub Actions check | Pre-merge regression protection | Ephemeral per workflow run |
| Windows/Jenkins-compatible monitor | Health contract for a separately managed container | External to the script |
| Telegram | Result delivery / observability | Not a health source of truth |

## Failure semantics

- A PostgreSQL readiness, write or exact read-back failure is a real failed health signal for the path being executed.
- Telegram transport failure never turns a healthy database signal red and never hides a database failure.
- The aggregate gate may combine validation signals, but it does not replace their evidence.
- Rerun-until-green loops, arbitrary sleeps and retries that conceal failures are not part of the monitoring strategy.

This boundary is documented explicitly so the portfolio demonstrates truthful observability engineering rather than overstating a synthetic check as production monitoring.
