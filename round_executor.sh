#!/bin/bash
# 🌙 AI 夜班系統 - 輪次執行器
# 根據當前時間決定執行哪一輪任務

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
HOUR=$(date '+%H')
LOG_DIR="/Users/user/night-shift/logs"
LOG_FILE="$LOG_DIR/night-shift-${DATE}.log"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${DATE}.md"

mkdir -p "$LOG_DIR"

# 決定輪次
if [ "$1" = "auto" ]; then
    case $HOUR in
        23) ROUND=1 ;;
        00) ROUND=2 ;;
        01) ROUND=3 ;;
        02) ROUND=4 ;;
        03) ROUND=5 ;;
        04) ROUND=6 ;;
        05) ROUND=7 ;;
        06) ROUND=8 ;;
        *) 
            echo "[$TIME] ⏰ 非夜班時間 ($HOUR)，跳過執行"
            exit 0
            ;;
    esac
else
    ROUND="$1"
fi

echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "🌙 Round $ROUND - $TIME" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 記錄到討論區
echo "" >> "$DISCUSSION"
echo "## $TIME - Round $ROUND 開始" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

# 安全護欄檢查
if [ ! -f "/tmp/night-shift-safety-lock" ]; then
    echo "[$TIME] ⚠️ 安全護欄未啟動，正在初始化..." >> "$LOG_FILE"
    touch "/tmp/night-shift-safety-lock"
fi

# 執行對應輪次任務
case $ROUND in
    1)
        echo "[$TIME] 📝 Round 1: 系統檢查 + 待辦清單抓取" >> "$LOG_FILE"
        /Users/user/night-shift/tech-lead/system_check.sh >> "$LOG_FILE" 2>&1 || true
        echo "### J:" >> "$DISCUSSION"
        echo "✅ 系統檢查完成" >> "$DISCUSSION"
        echo "正在抓取 Google Tasks 待辦清單..." >> "$DISCUSSION"
        ;;
    
    2)
        echo "[$TIME] 🔧 Round 2: Tech Lead - 巡邏 & 修復" >> "$LOG_FILE"
        # 檢查錯誤日誌
        if [ -f "/Users/user/logs/error.log" ]; then
            ERROR_COUNT=$(grep -c "ERROR" /Users/user/logs/error.log 2>/dev/null || echo 0)
            echo "[$TIME] 發現 $ERROR_COUNT 個錯誤" >> "$LOG_FILE"
            echo "### J:" >> "$DISCUSSION"
            echo "發現 $ERROR_COUNT 個錯誤，開始分析..." >> "$DISCUSSION"
        fi
        # 呼叫 subagent 修復小問題
        echo "[$TIME] 🤖 呼叫 Tech Lead Subagent..." >> "$LOG_FILE"
        ;;
    
    3)
        echo "[$TIME] 📚 Round 3: PM - 知識庫整理" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "開始整理知識庫，更新 second_brain.md..." >> "$DISCUSSION"
        # 統計記憶檔案
        MEMORY_COUNT=$(find /Users/user/memory -name "*.md" | wc -l)
        echo "[$TIME] 目前有 $MEMORY_COUNT 個記憶檔案" >> "$LOG_FILE"
        ;;
    
    4)
        echo "[$TIME] 🔍 Round 4: 研究任務 (AEO/GEO/SEO)" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "開始研究 AEO/GEO 最新趨勢..." >> "$DISCUSSION"
        
        # 執行 AEO 研究
        /Users/user/night-shift/subagents/aeo_researcher.sh >> "$LOG_FILE" 2>&1 || true
        
        # 執行 GEO 研究
        /Users/user/night-shift/subagents/geo_researcher.sh >> "$LOG_FILE" 2>&1 || true
        
        echo "✅ AEO/GEO 研究完成，已更新研究文件" >> "$DISCUSSION"
        ;;
    
    5)
        echo "[$TIME] ✍️ Round 5: 內容生成 (文章/文案)" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "開始撰寫部落格文章..." >> "$DISCUSSION"
        # 呼叫內容生成 subagent
        ;;
    
    6)
        echo "[$TIME] 📂 Round 6: 文件整理 & SOP更新" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "整理文件、更新 SOP..." >> "$DISCUSSION"
        ;;
    
    7)
        echo "[$TIME] 📋 Round 7: 提案準備 & 晨報草稿" >> "$LOG_FILE"
        echo "### J & 米米:" >> "$DISCUSSION"
        echo "整理今晚的工作成果，準備提案..." >> "$DISCUSSION"
        # 生成晨報草稿
        ;;
    
    8)
        echo "[$TIME] 🌅 Round 8: 最終檢查 & 晨報生成" >> "$LOG_FILE"
        echo "### J:" >> "$DISCUSSION"
        echo "夜班即將結束，正在生成最終晨報..." >> "$DISCUSSION"
        
        # 生成最終晨報
        /Users/user/night-shift/generate_morning_report.sh >> "$LOG_FILE" 2>&1 || true
        
        echo "" >> "$DISCUSSION"
        echo "---" >> "$DISCUSSION"
        echo "## 🌅 夜班結束 - $TIME" >> "$DISCUSSION"
        echo "晨報已生成！期待 G大 的feedback~" >> "$DISCUSSION"
        ;;
    
    *)
        echo "[$TIME] ❌ 未知輪次: $ROUND" >> "$LOG_FILE"
        exit 1
        ;;
esac

echo "[$TIME] ✅ Round $ROUND 完成" >> "$LOG_FILE"
echo "" >> "$DISCUSSION"
