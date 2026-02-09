@echo off
chcp 65001

:: --- ВНИМАНИЕ: ТОКЕН И ID ТЕПЕРЬ ПРИХОДЯТ ИЗ JENKINS ---

:: --- ПРОВЕРКА БАЗЫ ---
docker exec dev-postgres-db psql -U postgres -c "INSERT INTO robot_log (status) VALUES ('GitHub Clean Build - OK');" || (
    curl -k -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d chat_id=%CHAT_ID% -d text="🚨 AHTUNG! Baza upala! Proverka iz GitHub provalena."
    exit 1
)

:: --- УСПЕХ ---
curl -k -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d chat_id=%CHAT_ID% -d text="✅ USPEH! Skript bez paroley rabotaet!"

:: --- ОЧИСТКА ---
docker exec dev-postgres-db psql -U postgres -c "DELETE FROM robot_log WHERE visit_time < NOW() - INTERVAL '1 day';"