# 🌙 Night Shift System 夜班系統

AI 自動化夜間工作流程管理系統 - 讓 AI 在夜間持續工作，生成研究報告、整理知識庫、修復問題。

[![GitHub](https://img.shields.io/badge/GitHub-night--shift-blue)](https://github.com/gaskhuang/night-shift)

---

## 📁 倉庫結構

```
night-shift/
├── logs/               # 執行日誌檔案 (*.log)
├── reports/            # 生成的報告 (*.md, *.json)
├── research/           # 研究輸出 (AEO/GEO/SEO insights)
├── discussion/         # 團隊協作討論記錄 (*.md)
├── fixes/              # 修復記錄 (*.json)
├── proposals/          # 提案文件
├── tech-lead/          # Tech Lead (J) 腳本
├── pm-orchestrator/    # PM (米米) 腳本
├── subagents/          # 各類研究 subagent
├── *.sh                # 主要執行腳本
└── *.py                # Python orchestrator
```

---

## 🚀 自動上傳機制

本倉庫已整合 **自動推送到 GitHub** 功能，每輪執行後會自動同步以下檔案：

| 類型 | 檔案模式 | 說明 |
|------|----------|------|
| 日誌 | `logs/*.log` | 每輪執行的詳細日誌 |
| 報告 | `reports/*` | 系統狀態報告、晨報 |
| 研究 | `research/*.md` | AEO/GEO/SEO 研究輸出 |
| 討論 | `discussion/*.md` | J 和 米米 的協作記錄 |
| 修復 | `fixes/*.json` | Bug 修復記錄 |

### 自動推送觸發時機

- ✅ 每輪執行結束後（Round 1-8）
- ✅ 使用 `sync_and_push.sh` 手動觸發

---

## 🛠️ 手動同步工具

### 1. 快速同步並推送

```bash
cd /Users/user/night-shift-repo
./sync_and_push.sh "你的提交訊息"
```

### 2. 僅檢查並推送（在 repo 目錄中）

```bash
cd /Users/user/night-shift-repo
./auto_push.sh "自訂提交訊息"
```

---

## ⏰ 執行排程

| 時間 | Round | 負責 | 任務 |
|------|-------|------|------|
| 23:00 | 1 | J | 系統檢查 + 待辦抓取 |
| 00:00 | 2 | J | 巡邏 & 修復 |
| 01:00 | 3 | 米米 | 知識庫整理 |
| 02:00 | 4 | 米米 | AEO/GEO/SEO 研究 |
| 03:00 | 5 | 米米 | 內容生成 |
| 04:00 | 6 | 米米 | 文件整理 |
| 05:00 | 7 | J+米米 | 提案準備 |
| 06:00 | 8 | J+米米 | 晨報生成 |

---

## 🔧 設定

### 停用自動推送

編輯 `round_executor.sh`，將以下行改為 `false`：

```bash
GITHUB_SYNC_ENABLED=false
```

### 修改 GitHub 倉庫路徑

```bash
GITHUB_REPO_DIR="/你的/路徑/night-shift-repo"
```

---

## 👥 團隊成員

- **J (Tech Lead)** - 系統維護、錯誤修復、部署
- **米米 (PM)** - 知識管理、研究、內容生成

---

## 🔗 相關連結

- **GitHub Repository**: https://github.com/gaskhuang/night-shift
- **主專案**: OpenCRAW Master Workspace

---

*🦞 Powered by Lobster Intelligence*