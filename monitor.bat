@echo off
setlocal
chcp 65001 >nul

REM Runtime defaults. Jenkins normally provides BUILD_NUMBER, TOKEN and CHAT_ID.
if not defined DB_CONTAINER set "DB_CONTAINER=dev-postgres-db"
if not defined BUILD_NUMBER set "BUILD_NUMBER=manual"

set "NOTIFY_ENABLED=1"
if not defined TOKEN set "NOTIFY_ENABLED=0"
if not defined CHAT_ID set "NOTIFY_ENABLED=0"

if "%NOTIFY_ENABLED%"=="0" (
    echo INFO: Telegram credentials are not configured. Database health will still be evaluated.
)

set "EXPECTED_STATUS=Build #%BUILD_NUMBER% - OK"
set "READBACK_FILE=%TEMP%\qa-monitor-readback-%RANDOM%-%RANDOM%.txt"

REM The PostgreSQL persisted write/read check is the source of truth for this script.
docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -c "INSERT INTO robot_log (status) VALUES ('%EXPECTED_STATUS%');"
if errorlevel 1 goto :database_failure

docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -Atc "SELECT status FROM robot_log ORDER BY id DESC LIMIT 1;" > "%READBACK_FILE%"
if errorlevel 1 goto :database_failure

REM Require an exact persisted value; command success alone is not enough.
findstr /x /l /c:"%EXPECTED_STATUS%" "%READBACK_FILE%" >nul
if errorlevel 1 (
    echo ERROR: PostgreSQL read-back did not match the expected build status.
    goto :database_failure
)

del /q "%READBACK_FILE%" >nul 2>&1
echo INFO: Verified persisted PostgreSQL status "%EXPECTED_STATUS%".

REM Notification transport is auxiliary and must not change a healthy DB result.
if "%NOTIFY_ENABLED%"=="1" (
    curl --fail --silent --show-error --connect-timeout 10 --max-time 20 -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=✅ Build #%BUILD_NUMBER% passed: PostgreSQL write/read health check succeeded." || echo WARNING: Telegram success notification could not be delivered.
)

REM Retention cleanup is best-effort and must not overwrite the health signal.
docker exec "%DB_CONTAINER%" psql -U postgres -v ON_ERROR_STOP=1 -c "DELETE FROM robot_log WHERE visit_time < NOW() - INTERVAL '1 day';" || echo WARNING: PostgreSQL retention cleanup could not be completed.

endlocal
exit /b 0

:database_failure
del /q "%READBACK_FILE%" >nul 2>&1
if "%NOTIFY_ENABLED%"=="1" (
    curl --fail --silent --show-error --connect-timeout 10 --max-time 20 -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=🚨 Build #%BUILD_NUMBER% failed: PostgreSQL write/read health check is unavailable." || echo WARNING: Telegram failure notification could not be delivered.
)
endlocal
exit /b 1
