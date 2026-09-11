# Security Policy

This repository is a public QA monitoring portfolio project. It must not contain real Telegram credentials, Jenkins secrets or production database credentials.

## Supported state

Security and monitoring fixes are applied to the current `main` branch. Historical branches are not maintained as independently supported versions.

## Reporting a security concern

If a repository change exposes a credential or introduces unsafe monitoring behavior:

1. do not repost the secret in an issue, pull request, screenshot or log;
2. revoke/rotate an exposed credential immediately;
3. describe the affected component and risk without reproducing sensitive values;
4. use a private contact method from the maintainer's GitHub profile when the report itself contains sensitive information.

Deleting a committed secret is not sufficient by itself because Git history may still contain it.

## Current safeguards

- GitHub Actions uses read-only repository contents permission;
- operational Telegram credentials are read from GitHub Actions secrets;
- pull-request validation does not send Telegram notifications;
- `monitor.bat` expects Telegram values from its runtime/Jenkins environment and still evaluates database health when notifications are disabled;
- PostgreSQL write success/failure is kept separate from Telegram transport outcome;
- the Windows contract job verifies that observability failures cannot overwrite the database-health exit signal;
- the pinned PostgreSQL CI image has independent Trivy CRITICAL evidence and a retained CycloneDX SBOM;
- fixable CRITICAL findings remain blocking unless a compiler-level `gosu` finding is proven non-reachable on the exact extracted binary by pinned binary-mode `govulncheck`; all reachability evidence is retained with the scan;
- `CI / Required gate` aggregates the validation paths without hiding their independent results;
- the workflow uses an ephemeral PostgreSQL service credential for CI only; it is not a production secret.

Security or reliability checks should be fixed at their source. Do not weaken a failure signal solely to restore a green workflow.
