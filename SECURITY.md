# Политика безопасности

Это публичный портфолио-проект по QA-мониторингу. В репозитории **не должны** находиться реальные Telegram credentials, Jenkins secrets или production database credentials.

## Поддерживаемое состояние

Security- и monitoring-fixes применяются к текущей ветке `main`. Исторические ветки не поддерживаются как отдельные версии.

## Как сообщить о проблеме безопасности

Если изменение раскрыло credential или добавило небезопасное monitoring behavior:

1. не публикуйте secret повторно в Issue, Pull Request, screenshot или log;
2. немедленно отзовите/замените раскрытый credential;
3. опишите затронутый компонент и риск без воспроизведения чувствительных значений;
4. если сам отчёт содержит чувствительную информацию, используйте приватный контакт из GitHub-профиля владельца.

Удалить secret из текущего файла недостаточно: значение могло остаться в Git history.

## Текущие защитные меры

- GitHub Actions использует read-only permission к repository contents в рабочих validation workflows;
- operational Telegram credentials читаются из GitHub Actions secrets;
- Pull Request validation не отправляет реальные Telegram notifications;
- `monitor.bat` получает Telegram values из runtime/Jenkins environment и продолжает оценивать DB health, даже если notifications выключены;
- PostgreSQL health result отделён от Telegram transport outcome;
- Windows contract job проверяет, что observability failure не переписывает database-health exit signal;
- PostgreSQL CI image имеет независимый Trivy CRITICAL scan и сохраняемый CycloneDX SBOM;
- fixable `CRITICAL` findings блокируют workflow, кроме явно контролируемого compiler-level `gosu` finding, для которого non-reachability подтверждается на **точном извлечённом binary** pinned binary-mode `govulncheck`;
- scan, reachability и SBOM evidence сохраняются как artifacts;
- `CI / Required gate` агрегирует validation paths, не скрывая их независимые результаты;
- PostgreSQL credential внутри CI относится только к ephemeral service container и не является production secret.

Security и reliability findings должны исправляться в источнике. Нельзя ослаблять failure signal только ради возвращения workflow в green.
