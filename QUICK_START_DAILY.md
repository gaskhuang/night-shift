# 🚀 每日迭代系統 - 快速啟動指南

> 「每天 5 分鐘，讓你永遠知道下一步該做什麼」

---

## ⚡ 30 秒上手

```bash
# 啟動選單
/Users/user/night-shift/daily-iteration/quick_start.sh
```

---

## 🔄 每日流程

### 🌅 早上 (08:30) - 獲取行動推薦

```bash
# 查看 AI 推薦的今日最佳行動
python3 /Users/user/night-shift/daily-iteration/next_action_engine.py --today

# 或在選單中選 1
```

**輸出位置**: `night-shift/daily-iteration/recommendation.md`

**你會看到**:
- 🏆 TOP 3 推薦行動 (基於優先級 + 能量匹配 + 影響力)
- 🔄 低能量替代選項
- 📊 決策依據 (夜班成果 + 昨日意圖)

---

### 🌆 晚上 (22:00) - 每日覆盤

```bash
# 執行覆盤腳本
/Users/user/night-shift/daily-iteration/daily_review.sh

# 或在選單中選 2
```

**覆盤內容**:
1. ✅ 今日完成的事
2. 📊 今日數據 (任務數、專注時長、能量水平)
3. 💡 今日洞察 (新機會、教訓、意外收穫)
4. 🎯 明日意圖 (如果明天只能做一件事...)
5. 🔥 待孵化想法

**儲存位置**: `night-shift/evening/YYYY-MM-DD_Evening.md`

---

## 📅 每週流程

### 週日或週一 - 週規劃

```bash
# 自動建立或開啟本週規劃
# 在選單中選 3
```

**規劃內容**:
- 🎯 本週主題
- 📊 上週回顧
- 🚀 本週必做的 3 件事
- 📅 時間塊規劃

**模板位置**: `night-shift/planning/WEEK-TEMPLATE.md`

---

## 🗓️ 每月流程

### 每月 1 號或最後一天 - 月規劃

```bash
# 自動建立或開啟本月規劃
# 在選單中選 4
```

**規劃內容**:
- 🎯 本月主題
- 🔮 月度願景
- 🎯 月度 OKR
- 🏗️ 專案分解到每週
- 🎨 本月實驗

**模板位置**: `night-shift/planning/MONTH-TEMPLATE.md`

---

## 🎮 進階使用

### 根據能量狀態獲取推薦

```bash
# 高能量時 (適合創造性工作)
python3 next_action_engine.py --energy high

# 中能量時 (適合執行任務)
python3 next_action_engine.py --energy medium

# 低能量時 (適合整理維護)
python3 next_action_engine.py --energy low
```

### 查看系統狀態

```bash
# 在選單中選 7
```

顯示:
- 最近的覆盤記錄
- 待辦任務數量
- 最新晨報

---

## 🔧 自動化設定 (可選)

### 加入 Cron 自動執行

```bash
# 編輯 crontab
crontab -e

# 每天早上 08:30 生成推薦
30 8 * * * /Users/user/night-shift/daily-iteration/next_action_engine.py --today

# 每天晚上 22:00 提醒覆盤  
0 22 * * * /Users/user/night-shift/daily-iteration/daily_review.sh
```

---

## 📁 重要檔案位置

| 檔案類型 | 位置 |
|----------|------|
| 今日推薦 | `night-shift/daily-iteration/recommendation.md` |
| 覆盤記錄 | `night-shift/evening/YYYY-MM-DD_Evening.md` |
| 週規劃 | `night-shift/planning/WEEK-XX.md` |
| 月規劃 | `night-shift/planning/MONTH-YYYY-MM.md` |
| 待辦任務 | `memory/TASK_LIST.md` |
| 晨報 | `night-shift/reports/morning-report-*.md` |

---

## 💡 使用技巧

### 1. 早晨儀式 (5 分鐘)
1. 閱讀夜班晨報
2. 查看今日行動推薦
3. 選擇 #1 推薦，專注執行

### 2. 工作模式
- **高能量時**: 做火箭型任務 (🚀 開發、設計、戰略)
- **中能量時**: 做維護型任務 (🔄 協作、執行、溝通)
- **低能量時**: 做快速型任務 (⚡ 審批、回覆、整理)

### 3. 晚上儀式 (5 分鐘)
1. 執行 daily_review.sh
2. 填寫覆盤內容
3. 設定明日意圖

---

## 🆘 常見問題

**Q: 沒有看到推薦？**
A: 確保 `memory/TASK_LIST.md` 有待辦任務，格式為 `- [ ] 任務內容`

**Q: 推薦不準確？**
A: 每天填寫覆盤，系統會學習你的能量模式和意圖

**Q: 如何調整推薦邏輯？**
A: 編輯 `next_action_engine.py` 中的 `score_action()` 函數

---

*系統版本: v1.0 | 與 Night Shift System 整合*
