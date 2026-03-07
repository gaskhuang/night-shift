# 🌙 AI 夜班系統 - 快速啟動指南

## 1. 系統概述

這是一個讓你的 AI 模型（Claude、OpenAI、Codex、Kimi）在你睡覺時自動工作的系統。

### 團隊成員
- **🧑‍💻 Tech Lead - J**: 系統巡邏、修bug、寫程式
- **📊 PM - 米米**: 知識庫整理、研究、文章撰寫

### 執行時間
每晚 23:00 ~ 06:00，每小時一輪，共8輪

---

## 2. 快速啟動

### Step 1: 安裝 Cron 排程
```bash
# 查看目前的 cron 設定
crontab -l

# 安裝夜班排程
cat /Users/user/night-shift/cron_setup.txt | crontab -

# 驗證安裝
crontab -l | grep night-shift
```

### Step 2: 手動測試
```bash
# 進入夜班目錄
cd /Users/user/night-shift

# 測試 Round 1 (系統檢查)
./round_executor.sh 1

# 測試晨報生成
./generate_morning_report.sh

# 使用 Python 調度器測試
python3 subagent_orchestrator.py status
python3 subagent_orchestrator.py 1
```

### Step 3: 啟動夜班
```bash
# 手動啟動（今晚立即開始）
./start_night_shift.sh

# 或等待 cron 自動啟動（23:00）
```

---

## 3. 安全護欄

### ✅ 允許執行
- 讀取檔案、分析日誌
- 修小bug（測試環境）
- 重啟掛掉的服務
- 寫文章、整理文件
- 抓資料、做研究

### ❌ 禁止執行（會被自動攔截）
- 刪除重要檔案
- 修改 API Key
- 發訊息到任何群組
- 部署新功能到正式環境

---

## 4. 查看結果

### 晨報位置
```
night-shift/reports/morning-report-YYYY-MM-DD.md
```

### 團隊討論區
```
night-shift/discussion/collaboration_YYYY-MM-DD.md
```

### 執行日誌
```
night-shift/logs/night-shift-YYYY-MM-DD.log
```

### AEO/GEO 研究
```
night-shift/research/aeo_insights.md
night-shift/research/geo_insights.md
```

---

## 5. 常見問題

### Q: 如何調整執行時間？
編輯 `cron_setup.txt`，修改時間後重新安裝：
```bash
crontab -e
```

### Q: 如何新增任務？
編輯 `round_executor.sh`，在對應的 round case 中加入新任務。

### Q: 如何整合 Google Tasks？
需要設定 Google OAuth2：
1. 前往 Google Cloud Console
2. 啟用 Tasks API
3. 下載 credentials.json
4. 放到 `night-shift/config/`

### Q: 如何查看系統狀態？
```bash
python3 subagent_orchestrator.py status
```

---

## 6. 目錄結構

```
night-shift/
├── NIGHT_SHIFT_SYSTEM.md       # 系統文件
├── QUICK_START.md              # 本文件
├── start_night_shift.sh        # 啟動腳本 ⭐
├── round_executor.sh           # 輪次執行器 ⭐
├── safety_guardian.sh          # 安全守護
├── generate_morning_report.sh  # 晨報生成器
├── cron_setup.txt              # Cron 排程設定
├── subagent_orchestrator.py    # Python 調度器 ⭐
├── tech-lead/
│   └── system_check.sh         # 系統檢查
├── pm-orchestrator/
│   ├── task_sync.py            # Google Tasks 同步
│   └── content_generator.py    # 內容生成
├── subagents/
│   ├── aeo_researcher.sh       # AEO 研究
│   └── geo_researcher.sh       # GEO 研究
├── discussion/                 # 團隊討論區
├── reports/                    # 報告輸出 ⭐
├── logs/                       # 執行日誌
└── research/                   # 研究文件 ⭐
```

---

## 7. 後續優化方向

- [ ] 整合真實的 AI 模型 API (Claude/OpenAI/Codex)
- [ ] Google Tasks API 完整整合
- [ ] 自動部署到 WordPress/Medium
- [ ] 更多研究來源 (Twitter/Reddit/RSS)
- [ ] 智能錯誤修復 (自動 PR)
- [ ] Slack/Discord 通知整合

---

*開始燃燒你的 Token 吧！🔥*
