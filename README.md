# 🚀 Hybrid QA Monitoring System (Local & Cloud)

![GitHub Actions](https://img.shields.io/badge/GitHub_Actions-2088FF?style=for-the-badge&logo=github-actions&logoColor=white)
![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)

> 🇷🇺 **[Читать на русском языке](#-гибридная-система-мониторинга-qa-local--cloud)** (Scroll down for Russian)

---

## 🇺🇸 English Version

### 📌 Project Overview
This project demonstrates a **Hybrid CI/CD Pipeline** for database health monitoring. It is designed to run in two environments:
1.  **Cloud:** Fully automated using **GitHub Actions** (running on Ubuntu Linux).
2.  **Local:** Managed by **Jenkins** (running on Windows with Docker Desktop).

The system performs automated SQL queries to verify database integrity and sends instant notifications to Telegram.

### 🛠 Tech Stack
* **Cloud CI/CD:** GitHub Actions (Workflows, Cron Schedule, Secrets)
* **Local CI/CD:** Jenkins (Poll SCM, Batch Scripting)
* **Containerization:** Docker & Docker Service Containers
* **Database:** PostgreSQL (Alpine Linux)
* **Notifications:** Telegram Bot API
* **Version Control:** Git & GitHub

### ⚙️ How It Works

#### ☁️ Mode 1: Cloud (GitHub Actions)
* **Trigger:** Runs automatically every **10 minutes** (Cron) or manually via button.
* **Environment:** Ubuntu Latest (GitHub Runner).
* **Database:** GitHub spins up a temporary **PostgreSQL Service Container**.
* **Logic:**
    1.  Waits for DB to initialize (Healthcheck).
    2.  Creates a test table and inserts a record.
    3.  Sends a report to Telegram using encrypted **GitHub Secrets**.
    4.  Destroys the container after the test.

#### 🏠 Mode 2: Local (Jenkins)
* **Trigger:** Runs automatically on `git push` (Poll SCM).
* **Environment:** Local Windows Machine.
* **Database:** Persistent Docker container (`dev-postgres-db`).
* **Logic:**
    1.  Detects changes in the repository.
    2.  Executes `monitor.bat`.
    3.  Inserts a log record into the running local container.
    4.  Sends a success/failure alert to Telegram.

### 🚀 Usage (Run Locally)
1.  Ensure Docker Desktop is running.
2.  Start the PostgreSQL container:
    ```bash
    docker run --name dev-postgres-db -e POSTGRES_PASSWORD=mysecretpassword -d postgres
    ```
3.  Execute the monitoring script manually or via Jenkins:
    ```cmd
    monitor.bat
    ```

---
---

## 🇷🇺 Гибридная Система Мониторинга QA (Local & Cloud)

### 📌 Описание проекта
Этот проект реализует **Гибридный CI/CD пайплайн** для автоматического мониторинга базы данных. Система работает в двух режимах:
1.  **В облаке (Cloud):** Полностью автоматически через **GitHub Actions** (на серверах Linux).
2.  **Локально (Local):** Под управлением **Jenkins** (на Windows с Docker Desktop).

Скрипт выполняет тестовые SQL-запросы для проверки работоспособности базы данных и мгновенно отправляет отчет в Telegram.

### 🛠 Стек технологий
* **Cloud CI/CD:** GitHub Actions (Workflows, Cron, Secrets)
* **Local CI/CD:** Jenkins (Poll SCM, Batch Scripting)
* **Контейнеризация:** Docker & Docker Service Containers
* **База данных:** PostgreSQL
* **Уведомления:** Telegram Bot API
* **Контроль версий:** Git & GitHub

### ⚙️ Как это работает

#### ☁️ Режим 1: Облако (GitHub Actions)
* **Запуск:** Автоматически каждые **10 минут** или вручную по кнопке.
* **Среда:** Виртуальная машина Ubuntu.
* **База данных:** Временный **Service Container** (создается на 1 минуту).
* **Логика:**
    1.  GitHub поднимает чистую базу PostgreSQL.
    2.  Скрипт создает таблицу и делает тестовую запись.
    3.  Результат отправляется в Telegram (токены скрыты в GitHub Secrets).
    4.  Контейнер уничтожается после теста.

#### 🏠 Режим 2: Локально (Jenkins)
* **Запуск:** Автоматически при `git push` (Poll SCM).
* **Среда:** Локальный компьютер (Windows).
* **База данных:** Постоянный контейнер Docker.
* **Логика:**
    1.  Jenkins видит изменения в коде.
    2.  Запускает файл `monitor.bat`.
    3.  Проверяет локальную базу данных.
    4.  Шлет уведомление (Успех/Ошибка) в Telegram.

### 🚀 Как запустить локально
1.  Убедитесь, что Docker Desktop запущен.
2.  Запустите контейнер с базой:
    ```bash
    docker run --name dev-postgres-db -e POSTGRES_PASSWORD=mysecretpassword -d postgres
    ```
3.  Запустите скрипт проверки (вручную или через Jenkins):
    ```cmd
    monitor.bat
    ```

---

*Project created by Tokhirjon Yuldoshev as part of QA Automation Portfolio.*
