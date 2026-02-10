# 🚀 Hybrid QA Monitoring System
### Automated Database Health Check & Alerting

<p align="center">
  <img src="https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white" />
  <img src="https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white" />
  <img src="https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white" />
  <img src="https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" />
</p>

<p align="center">
  <a href="#-english-version">🇺🇸 <b>English Version</b></a>
  &nbsp;&nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;
  <a href="#-русская-версия">🇷🇺 <b>Русская версия</b></a>
</p>

---

<a name="english-version"></a>
## 🇺🇸 English Version

### 📌 Project Overview
This project implements a **Hybrid CI/CD Pipeline** for automated database monitoring. It ensures database availability by running scheduled SQL tests in two environments: **Cloud** (GitHub Actions) and **Local** (Jenkins).

**Key Feature:** The system automatically detects failures (e.g., database down, connection timeout) and sends instant alerts to a Telegram bot.

---

### 📂 Project Structure
```text
qa-docker-monitor/
├── .github/
│   └── workflows/
│       └── main.yml      # ☁️ Cloud Pipeline (GitHub Actions)
├── monitor.bat           # 🏠 Local Script (Windows/Jenkins)
├── README.md             # 📄 Documentation
└── .git/                 # 🐙 Git History
```

---

### 🛠 Tech Stack

| Component     | Technology      | Role |
|--------------|----------------|------|
| Cloud CI/CD  | GitHub Actions | Runs tests on Ubuntu (Cron schedule) |
| Local CI/CD  | Jenkins        | Runs tests on local Windows PC |
| Container    | Docker         | Hosts the PostgreSQL database |
| Database     | PostgreSQL     | Target for SQL tests |
| Alerting     | Telegram API   | Sends success/error notifications |

---

### ⚙️ How It Works

#### ☁️ Mode 1: Cloud (GitHub Actions)
- Runs automatically every 10 minutes.
- **Boot:** GitHub spins up an `ubuntu-latest` runner.
- **Service:** Creates a temporary PostgreSQL service container.
- **Test:** Executes SQL `INSERT` command to verify write access.
- **Report:** Sends status to Telegram using encrypted Secrets.
- **Cleanup:** Container and runner are destroyed after the test.

#### 🏠 Mode 2: Local (Jenkins)
- Runs automatically on Git push.
- **Trigger:** Jenkins Poll SCM detects changes.
- **Execute:** Runs `monitor.bat` script.
- **Check:** Connects to the persistent local Docker container.
- **Report:** Sends Build #ID status to Telegram.

---

### 📸 Notification Examples

| Status | Telegram Message |
|--------|------------------|
| ✅ Success | ☁️ CLOUD: Success! System is healthy. |
| 🚨 Failure | 🔥 CLOUD: ALERT! Test failed. Database is down. |

---

<a name="russian-version"></a>
## 🇷🇺 Русская версия

### 📌 Описание проекта
Этот проект реализует **гибридную систему мониторинга**, которая автоматически проверяет здоровье базы данных.  
Система работает в двух режимах: **Облако (GitHub Actions)** и **Локально (Jenkins)**.

**Главная фишка:** система сама находит ошибки (падение базы, обрыв связи) и мгновенно шлёт уведомление в Telegram.

---

### 📂 Структура проекта
```text
qa-docker-monitor/
├── .github/
│   └── workflows/
│       └── main.yml      # ☁️ Сценарий для облака (GitHub Actions)
├── monitor.bat           # 🏠 Сценарий для Windows (Jenkins)
├── README.md             # 📄 Документация
└── .git/                 # 🐙 История изменений
```

---

### 🛠 Стек технологий

| Компонент      | Технология      | Роль |
|---------------|----------------|------|
| Cloud CI/CD   | GitHub Actions | Запуск тестов на Ubuntu (по расписанию) |
| Local CI/CD   | Jenkins        | Запуск тестов на домашнем ПК |
| Контейнер     | Docker         | Запуск изолированной базы данных |
| База данных   | PostgreSQL     | Объект тестирования (SQL-запросы) |
| Алертинг      | Telegram API   | Отправка отчётов в чат |

---

### ⚙️ Как это работает

#### ☁️ Режим 1: Облако (GitHub Actions)
- Запускается автоматически каждые 10 минут.
- **Старт:** GitHub выделяет виртуальную машину Ubuntu.
- **Сервис:** Поднимается временный контейнер PostgreSQL.
- **Тест:** Скрипт создаёт таблицу и делает `INSERT`.
- **Отчёт:** Результат отправляется в Telegram (секреты в GitHub Secrets).
- **Финиш:** Контейнер и машина удаляются.

#### 🏠 Режим 2: Локально (Jenkins)
- Запускается автоматически при Git push.
- **Триггер:** Jenkins обнаруживает изменения.
- **Скрипт:** Запускается файл `monitor.bat`.
- **Проверка:** Подключение к локальному Docker-контейнеру.
- **Отчёт:** В Telegram отправляется номер сборки и статус.

---

<p align="center">
<i>Project created by Tokhirjon Yuldoshev for QA Automation Portfolio.</i>
</p>
