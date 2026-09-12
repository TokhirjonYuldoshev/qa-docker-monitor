## Краткое описание

<!-- Опишите одну сфокусированную monitoring/QA задачу и зачем она нужна. -->

## Область риска

- [ ] PostgreSQL health probe
- [ ] Windows/Jenkins monitor contract
- [ ] GitHub Actions / schedule / quality gate
- [ ] Telegram observability
- [ ] Docker / runtime configuration
- [ ] Только документация

## Evidence проверки

- [ ] `PostgreSQL write/read health check`
- [ ] `Windows monitor contract`, если изменение не относится только к schedule
- [ ] `CI / Required gate`
- [ ] Telegram behavior проверено, если менялась notification logic
- [ ] Scheduled-run semantics проверены, если менялись cron/conditions

Ссылки на run/evidence:

<!-- Добавляйте ссылки, когда они действительно помогают review или triage. -->

## Защита сигналов

- [ ] PostgreSQL write/read result остаётся source of truth для DB health
- [ ] Notification/cleanup failure не может переписать DB health result
- [ ] PR validation не отправляет реальные Telegram notifications
- [ ] В репозиторий не попали реальные token, chat ID, password или другие credentials
- [ ] Windows contract tests покрывают изменённые failure semantics batch-скрипта
- [ ] Scheduled runs не расходуют unrelated validation без необходимости
- [ ] Retry/sleep не добавлены только ради превращения failing check в green
- [ ] README и фактическое поведение workflow согласованы

## Классификация исходной ошибки

Если PR исправляет failure, укажите исходный owning signal:

- [ ] PostgreSQL / monitored dependency failure
- [ ] Monitor script / contract defect
- [ ] CI environment / runner failure
- [ ] Telegram / observability failure
- [ ] Configuration / credential failure
- [ ] Не применимо
