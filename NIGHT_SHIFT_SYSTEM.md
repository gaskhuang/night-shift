# 🌙 AI 夜班系統 (Night Shift System)

> 「AI 不是用來取代你的，是用來延伸你的工作時間」

## 系統概述

這是一個多模型協作的夜間自動化系統，讓你的AI團隊在你睡覺時持續運作，燃燒Token創造價值。

## 🏗️ 團隊架構

```
夜班團隊 Night Shift Team
├── 🧑‍💻 Tech Lead - J (技術長)
│   └── 負責：系統巡邏、修bug、寫程式、部署準備
├── 📊 PM - 米米 (專案經理)
│   └── 負責：知識庫整理、SOP更新、專案進度追蹤、研究
└── 💬 夜班討論區 (night-shift/discussion/collaboration.md)
    └── J & 米米的共用對話空間
```

## 🔄 分時啟動機制（防Rate Limit）

```
23:00 │ Round 1: 系統檢查 + 待辦清單抓取
00:00 │ Round 2: Tech Lead - 巡邏 & 修復
01:00 │ Round 3: PM - 知識庫整理
02:00 │ Round 4: 研究任務 (AEO/GEO/SEO)
03:00 │ Round 5: 內容生成 (文章/文案)
04:00 │ Round 6: 文件整理 & SOP更新
05:00 │ Round 7: 提案準備 & 晨報草稿
06:00 │ Round 8: 最終檢查 & 晨報生成
─────────────────────────────
08:00 │ G大起床 → 閱讀晨報
```

## 🛡️ 安全護欄 (絕對禁止)

| 類別 | 禁止事項 | 違規處理 |
|------|---------|---------|
| 🔴 高危 | 刪除重要檔案 | 立即停止，記錄到安全日誌 |
| 🔴 高危 | 修改 API Key | 立即停止，記錄到安全日誌 |
| 🔴 高危 | 發訊息到任何群組 | 立即停止，記錄到安全日誌 |
| 🔴 高危 | 部署新功能到正式環境 | 寫提案，等G大決定 |
| 🟡 中危 | 修改網站核心檔案 | 僅限 `openclaw-service/` 以外 |
| 🟡 中危 | 刪除任何檔案 | 用 `trash` 而非 `rm`，記錄備份 |

## ✅ 允許執行

- 讀取檔案、分析日誌
- 修小bug（測試環境）
- 重啟掛掉的服務（已有腳本）
- 寫文章、整理文件
- 抓資料、做研究
- 更新知識庫、SOP
- 生成晨報、提案

## 📋 任務清單

### Tech Lead (J) 任務
- [ ] 系統狀態檢查 (磁碟、記憶體、服務)
- [ ] 檢查今日錯誤日誌
- [ ] 從 Google Tasks 抓取待辦事項
- [ ] 修復已知小bug
- [ ] 優化現有腳本
- [ ] 準備部署提案

### PM (米米) 任務
- [ ] 整理 memory/ 目錄
- [ ] 更新知識庫 (second_brain.md, lobster_second_brain.md)
- [ ] AEO (Answer Engine Optimization) 研究
- [ ] GEO (Generative Engine Optimization) 研究
- [ ] SEO 結構化數據更新
- [ ] 追蹤 TASK_LIST.md 進度
- [ ] 撰寫部落格文章

## 📝 夜班討論區格式

位置：`night-shift/discussion/collaboration_YYYY-MM-DD.md`

```markdown
# 夜班討論區 - 2026-03-07

## 23:00 Round 1 開始

### J:
今晚系統狀態正常，發現昨日日誌有2個警告。
待辦清單已抓取：3個P0任務。

### 米米:
收到。我會優先研究 AEO 最新趨勢。
對了，我發現一篇好文章，J你看看能不能整合到工具裡？
[連結]

### J:
可以，我02:00輪次來處理。

---

## 00:00 Round 2 開始
...
```

## 📰 晨報格式

位置：`night-shift/reports/morning-report_YYYY-MM-DD.md`

```markdown
# 🌅 夜班晨報 - 2026-03-07

## 📊 系統狀態
- 磁碟使用: 78% (正常)
- 記憶體: 4.2GB/16GB (正常)
- 服務狀態: ✅ 全部正常

## ✅ 今晚完成工作

### Tech Lead (J)
1. 修復了 `xxx.py` 的編碼問題
2. 優化了 `search_tsmc_threads.py` 的錯誤處理
3. ...

### PM (米米)
1. 更新 AEO/GEO 研究文件
2. 撰寫部落格文章 2 篇
3. ...

## 🔍 發現的問題
| 問題 | 嚴重度 | 處理方式 |
|------|--------|---------|
| XXX | 低 | 已自動修復 |
| YYY | 中 | 需要G大決定 |

## 📋 需要決定的提案
1. **提案1**: XXX (建議：批准)
2. **提案2**: YYY (建議：暫緩)

## 💬 團隊討論摘要
- 米米發現了新的 AEO 趨勢
- J 建議整合到現有工具
- 決定先寫提案等G大決定

## 📅 明天建議
1. 優先處理 P0 任務：XXX
2. 考慮部署昨晚準備的優化
3. 繼續關注 YYY 議題

---
*自動生成 by AI夜班團隊 · 2026-03-07 06:00*
```

## 🎯 AEO/GEO 研究模組

### 研究來源
- Search Engine Journal
- OpenAI Blog
- Google Search Central Blog
- 行業領袖 Twitter/X
- Reddit r/SEO, r/bigseo

### 更新文件
- `night-shift/research/aeo_insights.md` - AEO 最新洞察
- `night-shift/research/geo_insights.md` - GEO 最新洞察
- `night-shift/research/seo_structured_data.md` - SEO 結構化數據範本

### 更新頻率
- 每晚02:00輪次自動更新
- 追加模式（保留舊內容，添加新內容）

## 🚀 啟動方式

### 手動啟動
```bash
# 啟動完整夜班
/Users/user/night-shift/start_night_shift.sh

# 啟動單一輪次
/Users/user/night-shift/round_executor.sh 1  # 執行Round 1
```

### Cron 排程
```
# 每小時執行一輪
0 23,0,1,2,3,4,5,6 * * * /Users/user/night-shift/round_executor.sh auto
```

## 🔧 模型配置

| 角色 | 模型 | 用途 |
|------|------|------|
| Tech Lead | Claude Sonnet 4-6 | 技術決策、程式修復 |
| PM | Kimi k2.5 | 統整、分析、文章撰寫 |
| 研究員 | Grok | 爬蟲、資料蒐集 |
| 輔助 | Codex | 程式生成、Code Review |

## 📁 目錄結構

```
night-shift/
├── NIGHT_SHIFT_SYSTEM.md      # 本文件
├── start_night_shift.sh        # 啟動腳本
├── round_executor.sh           # 輪次執行器
├── safety_guardian.sh          # 安全守護腳本
├── generate_morning_report.sh  # 晨報生成器
├── tech-lead/
│   ├── system_check.sh         # 系統檢查
│   ├── bug_fixer.py            # Bug修復模組
│   └── deployment_prep.py      # 部署準備
├── pm-orchestrator/
│   ├── task_sync.py            # Google Tasks同步
│   ├── knowledge_updater.py    # 知識庫更新
│   └── content_generator.py    # 內容生成
├── subagents/
│   ├── aeo_researcher.sh       # AEO研究員
│   ├── geo_researcher.sh       # GEO研究員
│   └── seo_structured.sh       # SEO結構化數據
├── discussion/                 # 團隊討論區
├── reports/                    # 報告輸出
└── logs/                       # 執行日誌
```

---

*系統版本: v1.0 | 建立: 2026-03-07 | G大的AI夜班團隊*
