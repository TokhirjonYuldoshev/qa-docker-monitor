@echo off
chcp 65001

:: --- ВНИМАНИЕ: ТОКЕН И ID ПРИХОДЯТ ИЗ JENKINS ---

:: --- ПРОВЕРКА БАЗЫ ---
docker exec dev-postgres-db psql -U postgres -c "INSERT INTO robot_log (status) VALUES ('Build #%BUILD_NUMBER% - OK');" || (
    curl -k -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d chat_id=%CHAT_ID% -d text="🚨 Oshibka! Sborka #%BUILD_NUMBER% upala! Baza nedostupna."
    exit 1
)

:: --- УСПЕХ ---
:: Смотри сюда: я добавил %BUILD_NUMBER% в текст
curl -k -X POST "https://api.telegram.org/bot%TOKEN%/sendMessage" -d chat_id=%CHAT_ID% -d text="✅ Sborka #%BUILD_NUMBER% uspeshna! Avto-test proiden."

:: --- ОЧИСТКА ---
docker exec dev-postgres-db psql -U postgres -c "DELETE FROM robot_log WHERE visit_time < NOW() - INTERVAL '1 day';"