## Summary

<!-- Describe one focused monitoring/QA outcome and why it is needed. -->

## Risk area

- [ ] PostgreSQL health probe
- [ ] Windows/Jenkins monitor contract
- [ ] GitHub Actions / scheduling / quality gate
- [ ] Telegram observability
- [ ] Docker / runtime configuration
- [ ] Documentation only

## Verification evidence

- [ ] `PostgreSQL write health check`
- [ ] `Windows monitor contract` when not schedule-only
- [ ] `CI / Required gate`
- [ ] Telegram behavior reviewed if notification logic changed
- [ ] Scheduled-run semantics reviewed if cron/conditions changed

Evidence / run links:

<!-- Add run links only when they improve triage/review. -->

## Signal safeguards

- [ ] PostgreSQL write result remains the source of truth for DB health
- [ ] Notification/cleanup failure cannot overwrite the DB health result
- [ ] PR validation does not send real Telegram notifications
- [ ] No real token, chat ID, password or credential was committed
- [ ] Windows contract tests cover changed batch-script failure semantics
- [ ] Scheduled runs do not consume unrelated validation unnecessarily
- [ ] No retry/sleep was added merely to make a failing check green
- [ ] README and workflow behavior remain aligned

## Failure classification

If this PR responds to a failure, classify the original signal:

- [ ] PostgreSQL / monitored dependency failure
- [ ] Monitor script / contract defect
- [ ] CI environment / runner failure
- [ ] Telegram / observability failure
- [ ] Configuration / credential failure
- [ ] Not applicable
