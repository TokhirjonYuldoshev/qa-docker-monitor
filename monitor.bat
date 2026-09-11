@echo off
setlocal
chcp 65001 >nul

REM Runtime defaults. Jenkins normally provides BUILD_NUMBER, TOKEN and CHAT_ID.
if not defined DB_CONTAINER set "DB_CONTAINER=dev-postgres-db"
if not defined BUILD_NUMBER set "BUILD_NUMBER=manual"
if not defined RUN_TOKEN set "RUN_TOKEN=%RANDOM%-%RANDOM%"

set "NOTIFY_ENABLED=1"
if not defined TOKEN set "NOTIFY_ENABLED=0"
if not defined CHAT_ID set "NOTIFY_ENABLED=0"

if "%NOTIFY_ENABLED%"=="0" (
    echo INFO: Telegram credentials are not configured. Database health will still be evaluated.
)

REM The per-run token prevents another writer from becoming the row we validate.
set "EXPECTED_STATUS=Build #%BUILD_NUMBER% - OK [%RUN_TOKEN%]"
set "READBACK_FILE=%TEMP%\qa-monitor-readback-%RANDOM%-%RANDOM%.txt"

REM CALL keeps control in this script when CI substitutes .cmd command doubles.
REM With real docker.exe/curl.exe it preserves the same command semantics.
call docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -c "INSERT INTO robot_log (status) VALUES ('%EXPECTED_STATUS%');"
if errorlevel 1 goto :database_failure

REM Read back this run's exact marker instead of assuming the globally newest row is ours.
call docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -Atc "SELECT status FROM robot_log WHERE status = '%EXPECTED_STATUS%' ORDER BY id DESC LIMIT 1;" > "%READBACK_FILE%"
if errorlevel 1 goto :database_failure

REM PowerShell performs an exact trimmed comparison and returns a machine-readable exit code.
powershell.exe -NoLogo -NoProfile -NonInteractive -Command "$actual = (Get-Content -LiteralPath $env:READBACK_FILE -Raw).Trim(); if ($actual -cne $env:EXPECTED_STATUS) { Write-Error ('Read-back mismatch. Expected: ' + $env:EXPECTED_STATUS + '; actual: ' + $actual); exit 1 }"
if errorlevel 1 goto :database_failure

del /q "%READBACK_FILE%" >nul 2>&1
echo INFO: Verified persisted PostgreSQL status "%EXPECTED_STATUS%".

REM Notification transport is auxiliary and must not change a healthy DB result.
if "%NOTIFY_ENABLED%"=="1" (
    call curl --fail --silent --show-error --connect-timeout 10 --max-time 20 -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=✅ Build #%BUILD_NUMBER% passed: PostgreSQL write/read health check succeeded." || echo WARNING: Telegram success notification could not be delivered.
)

REM Retention cleanup is best-effort and must not overwrite the health signal.
call docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -c "DELETE FROM robot_log WHERE visit_time < NOW() - INTERVAL '1 day';" || echo WARNING: PostgreSQL retention cleanup could not be completed.

endlocal
exit /b 0

:database_failure
del /q "%READBACK_FILE%" >nul 2>&1
if "%NOTIFY_ENABLED%"=="1" (
    call curl --fail --silent --show-error --connect-timeout 10 --max-time 20 -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=🚨 Build #%BUILD_NUMBER% failed: PostgreSQL write/read health check is unavailable." || echo WARNING: Telegram failure notification could not be delivered.
)
endlocal
exit /b 1
