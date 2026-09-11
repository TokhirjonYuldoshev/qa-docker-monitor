# Monitoring Incident Runbook

This runbook defines how to triage failures in `QA Database Health Monitor` without collapsing independent signals into one generic "CI failed" outcome.

## Signal ownership

| Signal | Source of truth | Blocking? | First owner action |
| --- | --- | --- | --- |
| PostgreSQL write/read health | `database-health` job | Yes | Inspect SQL/read-back failure before touching notifications |
| Windows monitor contract | `windows-contract` job | Yes for PR/push/manual | Identify which exit-code scenario regressed |
| Aggregate gate | `CI / Required gate` | Yes | Confirm which upstream required signal is non-success |
| Telegram delivery | `notify` job / Telegram diagnostic | No | Treat as observability transport unless DB health also failed |

## Triage order

1. **Read the aggregate summary.** Identify whether PostgreSQL health, Windows contract, or both are failing.
2. **Open the failing source job**, not the notification job. The source job owns the real quality signal.
3. **Classify the failure** as database health, contract regression, infrastructure/runner problem, or notification transport.
4. **Collect evidence** from the failing step and workflow metadata: trigger, branch, commit, run ID, and exact command/output.
5. **Reproduce only the smallest failing path.** Do not add retries, sleeps, or notification suppression to make the workflow green.
6. **Fix the owning layer** and validate through the normal PR gate before merge.

## PostgreSQL health failure

A red `PostgreSQL write/read health check` means the workflow failed to prove persisted database state.

Check in this order:

- service readiness and container startup;
- `psql` connectivity/authentication;
- `CREATE TABLE` result;
- `INSERT` result;
- exact read-back count for the current run marker;
- runner/network/platform evidence if the database service never became usable.

Expected invariant:

```text
CREATE succeeds -> INSERT succeeds -> SELECT returns exactly one row for this run marker
```

A successful port check or process status is **not** sufficient evidence of database health.

## Windows contract failure

The Windows job validates `monitor.bat` failure semantics with isolated command doubles. A failure here is a regression in orchestration logic, not evidence that production PostgreSQL is unhealthy.

Expected contract:

| Scenario | Expected exit |
| --- | ---: |
| DB write/read succeeds, Telegram disabled | `0` |
| DB write/read succeeds, Telegram fails | `0` |
| DB read-back mismatch | `1` |
| DB command fails, Telegram also fails | `1` |

If a scenario fails, inspect the batch script exit-code path first. Do not make Telegram success a prerequisite for database health.

## Telegram-only failure

If the required gate is green but notification delivery fails:

- keep the monitoring run **healthy**;
- use the manual Telegram diagnostic workflow to distinguish missing secrets, invalid bot token, invalid chat target, and API transport failure;
- do not change database-health semantics to compensate for a notification outage.

## Runner or platform incident

Evidence of an external CI/platform problem includes failures before project logic runs, package/service provisioning failures, or unrelated runner/network errors.

For suspected external incidents:

- preserve the original failed run;
- verify the same commit/configuration did not change the failing project logic;
- allow at most one targeted diagnostic rerun after there is concrete evidence the external condition has recovered;
- do not introduce permanent retries or sleeps to hide the incident.

## Severity model

| Severity | Example | Response |
| --- | --- | --- |
| SEV-1 | Repeated scheduled DB health failure with confirmed write/read failure | Treat as service-health incident; investigate immediately |
| SEV-2 | Required contract/gate regression on `main` | Stop further changes until signal ownership is restored |
| SEV-3 | Telegram unavailable while required health gate is green | Repair observability transport; DB health remains valid |
| SEV-4 | Documentation/summary presentation issue | Fix through normal PR flow |

## Exit criteria

An incident is considered resolved only when:

- the owning signal passes for the corrected revision;
- `CI / Required gate` reflects the upstream results correctly;
- no retry/sleep workaround was added to mask the root cause;
- documentation is updated when the incident exposed a missing operational rule.

## Anti-patterns

Do not:

- treat Telegram delivery as the source of truth for PostgreSQL health;
- downgrade a real SQL/read-back failure to a warning;
- add arbitrary delays to make timing-sensitive failures disappear;
- merge a monitoring-logic change while its required validation is red;
- rerun repeatedly until a random green result appears.
