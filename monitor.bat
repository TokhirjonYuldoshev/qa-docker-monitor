@echo off
setlocal
chcp 65001 >nul

REM Expected environment variables are provided by Jenkins:
REM TOKEN, CHAT_ID and BUILD_NUMBER.

set "DB_CONTAINER=dev-postgres-db"

REM Verify database write capability.
docker exec %DB_CONTAINER% psql -U postgres -v ON_ERROR_STOP=1 -c "INSERT INTO robot_log (status) VALUES ('Build #%BUILD_NUMBER% - OK');"
if errorlevel 1 (
    curl --fail --silent --show-error -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=🚨 Build #%BUILD_NUMBER% failed: PostgreSQL health check is unavailable."
    exit /b 1
)

curl --fail --silent --show-error -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d "chat_id=%CHAT_ID%" --data-urlencode "text=✅ Build #%BUILD_NUMBER% passed: PostgreSQL write health check succeeded."

docker exec %DB_CONTAINER% psql -U postgres -v ON_ERROR_STOP=1 -c "DELETE FROM robot_log WHERE visit_time < NOW() - INTERVAL '1 day';"

endlocal
