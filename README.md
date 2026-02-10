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
This project implements a **Hybrid CI/CD Pipeline** for automated database monitoring. It ensures database availability by running scheduled SQL tests in two different environments: **Cloud** (GitHub Actions) and **Local** (Jenkins).

> **Key Feature:** The system automatically detects failures (e.g., database down, connection timeout) and sends instant alerts to a Telegram bot.

### 📂 Project Structure
```text
qa-docker-monitor/
├── .github/
│   └── workflows/
│       └── main.yml      # ☁️ Cloud Pipeline (GitHub Actions)
├── monitor.bat           # 🏠 Local Script (Windows/Jenkins)
├── README.md             # 📄 Documentation
└── .git/                 # 🐙 Git History
