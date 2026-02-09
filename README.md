# 🚀 Automated QA Monitoring System

![Jenkins](https://img.shields.io/badge/Jenkins-D24939?style=for-the-badge&logo=Jenkins&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=for-the-badge&logo=postgresql&logoColor=white)
![Telegram](https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white)

## 📌 Project Overview
This project implements a fully automated CI/CD pipeline for database health monitoring. It demonstrates the integration of **Jenkins**, **Docker**, and **Telegram API** to perform automated checks and instant notifications.

The system automatically:
1.  Detects code changes in GitHub.
2.  Triggers a Jenkins build.
3.  Executes SQL queries inside a Dockerized PostgreSQL container.
4.  Reports the status (Success/Failure) directly to a Telegram bot.

---

## 🛠 Tech Stack
* **CI/CD:** Jenkins (Poll SCM Trigger)
* **Containerization:** Docker (PostgreSQL)
* **Scripting:** Windows Batch / Shell
* **Notifications:** Telegram Bot API
* **Version Control:** Git & GitHub

---

## ⚙️ How It Works
1.  **Code Commit:** Developer pushes code to the `main` branch.
2.  **Jenkins Trigger:** Jenkins detects changes (via Poll SCM) and pulls the latest code.
3.  **Execution:** The `monitor.bat` script runs inside the Jenkins environment.
4.  **Database Check:** A test record is inserted into the running PostgreSQL container.
5.  **Notification:** The result (Build Number + Status) is sent to the Telegram channel.

---

## 📸 Demo
*(Здесь ты потом можешь вставить скриншот из Telegram с успешным сообщением)*

---

## 🚀 Usage
To run this locally:
1.  Ensure Docker Desktop is running.
2.  Start the PostgreSQL container:
    ```bash
    docker run --name dev-postgres-db -e POSTGRES_PASSWORD=mysecretpassword -d postgres
    ```
3.  Execute the monitoring script:
    ```cmd
    monitor.bat
    ```

---

*Project created by Tokhirjon Yuldoshev as part of QA Automation Portfolio.*# qa-docker-monitor