# 🌙 AI 夜班系統 v2.5

> 「更頻繁的迭代，更快的回饋」
> 
> 更新：新增 08:30 今日行動推薦、第二大腦整合、思考模式

## 相較 v1.0 的改進

| 項目 | v1.0 | v2.5 |
|------|------|------|
| **任務間隔** | 每小時 | 每20分鐘 |
| **執行模式** | 單線程 | Subagent 平行處理 |
| **晨報後** | 僅閱讀 | 08:30 自動生成「今日行動推薦」 |
| **資料源** | 日誌/記憶 | 第二大腦 + 夜班推薦 + 待辦 |
| **推理模式** | DeepSeek-R1 (烤) | GPT-5.4 思考模式 |
| **總任務數** | 8輪 | 20+ 個細粒度任務 |

---

## 🔄 新排程表（每20分鐘）

```
23:00 │ 系統檢查 (同步)
23:20 │ 待辦同步 (Subagent)
─────────────────────────────
00:00 │ 日誌巡邏 (同步)
00:20 │ Bug修復 (Subagent)
─────────────────────────────
01:00 │ 記憶庫整理 (Subagent)
01:20 │ 知識庫同步 (Subagent)
─────────────────────────────
02:00 │ 研究協調 (同步)
02:20 │ AEO研究 (Subagent)
03:00 │ GEO研究 (Subagent)
03:20 │ 研究摘要 (Subagent)
─────────────────────────────
04:00 │ 內容生成 (Subagent)
04:20 │ 文件整理 (Subagent)
─────────────────────────────
05:00 │ 提案準備 (Subagent)
05:20 │ 晨報草稿 (Subagent)
─────────────────────────────
06:00 │ 最終檢查 & 晨報生成 (同步)
06:20 │ 清理任務 (Subagent)
─────────────────────────────
08:30 │ 🎯 今日行動推薦生成
```

---

## 🎯 今日行動推薦 (08:30)

每天早上 **08:30** 自動生成，回答「**下一步要做什麼**」：

```
🎯 今日行動推薦 - 2026-03-08

📊 決策依據
├─ 🌙 夜班晨報狀態
├─ 📋 待辦任務數量
├─ 🧠 第二大腦活躍專案
└─ 🔮 夜班推薦數量

🏆 TOP 3 推薦行動（下一步要做什麼）
├─ 🥇 #1 優先行動 (基於 P0 + 夜班高優先)
├─ 🥈 #2 次選行動 (基於 P0/P1 + 第二大腦)
└─ 🥉 #3 備選行動 (基於 P1/成長任務)

🧠 第二大腦洞察
├─ 進行中的專案
├─ 等待中的事項
└─ 下一步行動

🔮 夜班推薦摘要
├─ 高優先事項與解法
└─ 可自動執行的項目

🔄 能量調整建議
├─ 能量高 → 直接執行 #1
├─ 能量中 → 先做 #2，午休後做 #1
└─ 能量低 → 只做 5 分鐘版本
```

**推薦邏輯**: 結合
1. ✅ 夜班晨報成果
2. ✅ TASK_LIST P0/P1 優先級
3. ✅ 第二大腦 (second_brain.md, IDEA.md)
4. ✅ 昨日覆盤的「明日意圖」
5. ✅ 系統狀態數據

---

## 🤖 Subagent 平行處理

### 可以平行的任務 (背景執行)
- ✅ 待辦同步
- ✅ 記憶庫整理
- ✅ 知識庫同步
- ✅ AEO/GEO 研究
- ✅ 內容生成
- ✅ 文件整理
- ✅ 提案準備

### 需要同步的任務 (等待結果)
- ⏳ 系統檢查 (後續依賴)
- ⏳ 日誌巡邏 (決定修復策略)
- ⏳ 研究協調 (分配研究任務)
- ⏳ 最終檢查 (生成晨報)

---

## 📱 Telegram Bot 控制

### 指令選單

```
/start    - 啟動機器人並顯示主選單
/optimize - 🔧 系統優化 - 執行夜班系統檢查
/recommend- 🧠 第二大腦推薦 - 分析並推薦下一步行動
/think    - 💭 思考模式 - GPT-5.4 深度推理分析
/status   - 📊 查看系統狀態
/help     - 顯示使用說明
```

### 主選單按鈕

- 🔧 **系統優化** - 手動執行系統檢查與優化
- 🧠 **第二大腦推薦** - 從記憶庫分析並推薦下一步行動
- 💭 **思考模式** - 使用 GPT-5.4 進行深度推理分析
- 📊 **查看狀態** - 查看系統狀態

### 使用方式

```bash
# 啟動 Bot
/Users/user/night-shift/start_telegram_bot.sh

# 設定指令選單
python3 /Users/user/night-shift/setup_bot_menu.py

# 查看狀態
/Users/user/night-shift/status_telegram_bot.sh

# 停止 Bot
/Users/user/night-shift/stop_telegram_bot.sh
```

---

## 📁 檔案結構

```
night-shift/
├── orchestrator_v2.sh           # 新版排程器 (20分鐘間隔)
├── NIGHT_SHIFT_SYSTEM_v2.md     # 本文件
├── setup_cron_v2.sh             # Cron 設定腳本
├── telegram_bot.py              # Telegram Bot
├── setup_bot_menu.py            # Bot 選單設定
├── start_telegram_bot.sh        # 啟動 Bot
├── subagents/                   # Subagent 腳本
│   ├── todo_sync.sh
│   ├── memory_organizer.sh
│   ├── knowledge_sync.sh
│   ├── aeo_researcher.sh
│   ├── geo_researcher.sh
│   ├── content_generator.sh
│   ├── proposal_prep.sh
│   ├── draft_report.sh
│   ├── final_check.sh
│   ├── cleanup.sh
│   ├── recommendation_engine.sh # 智能推薦引擎
│   └── solution_proposer.sh     # 解法生成器
└── daily-iteration/
    ├── next_action_engine.py    # 08:30 行動推薦 (Python)
    ├── next_action_engine.sh    # 08:30 行動推薦 (Wrapper)
    └── recommendation.md        # 生成的推薦報告
```

---

## 🚀 快速開始

### 1. 安裝 Cron 設定
```bash
/Users/user/night-shift/setup_cron_v2.sh
```

### 2. 啟動 Telegram Bot
```bash
# 啟動 Bot
/Users/user/night-shift/start_telegram_bot.sh

# 設定選單
python3 /Users/user/night-shift/setup_bot_menu.py
```

### 3. 手動測試
```bash
# 測試排程器
/Users/user/night-shift/orchestrator_v2.sh

# 測試行動推薦
python3 /Users/user/night-shift/daily-iteration/next_action_engine.py --today

# 測試系統優化
python3 /Users/user/night-shift/telegram_bot.py
```

### 4. 查看今日推薦
```bash
cat /Users/user/night-shift/daily-iteration/recommendation.md
```

---

## ⏰ Cron 設定詳情

```
# 🌙 夜班: 每20分鐘
0,20,40 23 * * *     /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1
0,20,40 0,1,2,3,4,5 * * * /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1
0 6 * * *            /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1

# 🎯 每天早上 08:30 生成今日行動推薦
30 8 * * *           /Users/user/night-shift/daily-iteration/next_action_engine.sh >> /Users/user/night-shift/logs/cron.log 2>&1
```

---

## 💭 思考模式 (GPT-5.4)

使用方式：
```
/think 如何優化我的內容行銷策略？
/think 分析這個商業模式的風險點
/think 幫我拆解這個複雜問題
```

適用場景：
- 複雜問題的拆解與分析
- 需要多步驟邏輯推演的研究
- 策略規劃與決策建議

模型配置：
- 使用 OpenAI o3-mini (最先進的推理模型)
- 開啟思考模式
- 深度推理分析

---

## 📊 與 v1.0 的相容性

- 原有腳本仍可繼續使用
- `start_night_shift.sh` → 保留作為手動啟動
- `round_executor.sh` → 保留作為備份
- 討論區格式不變
- 晨報格式相容

---

## 🔐 安全護欄

夜班系統遵循以下安全原則：

- ✅ 可做：讀檔、修小bug、重啟服務、寫文章、整理文件
- ❌ 不可做：刪重要檔案、改API Key、發群組訊息、部署正式環境
- 📋 大改動寫提案，等 G大 決定

---

*系統版本: v2.5 | 更新: 2026-03-07 | G大的AI夜班團隊*
*功能：20分鐘間隔 + 平行處理 + 08:30推薦 + Telegram控制 + 思考模式*
