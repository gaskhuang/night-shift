#!/bin/bash
# 🤖 Subagent: 日誌巡邏
# 檢查系統日誌中的錯誤和異常

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_DIR="/Users/user/logs"

echo "[$TIME] 🔍 開始日誌巡邏..."

# 檢查錯誤日誌
if [ -f "$LOG_DIR/error.log" ]; then
    # 今日錯誤
    TODAY_ERRORS=$(grep "^${DATE}" "$LOG_DIR/error.log" 2>/dev/null | wc -l || echo 0)
    echo "[$TIME] 📊 今日錯誤數: $TODAY_ERRORS"
    
    if [ "$TODAY_ERRORS" -gt 0 ]; then
        echo "[$TIME] ⚠️ 發現錯誤，前3條:"
        grep "^${DATE}" "$LOG_DIR/error.log" 2>/dev/null | head -3
    fi
else
    echo "[$TIME] ℹ️ 無 error.log 檔案"
fi

# 檢查最近修改的日誌
if [ -d "$LOG_DIR" ]; then
    RECENT_LOGS=$(find "$LOG_DIR" -name "*.log" -mtime -1 2>/dev/null | wc -l)
    echo "[$TIME] 📁 最近24小時日誌檔案: $RECENT_LOGS 個"
fi

echo "[$TIME] ✅ 日誌巡邏完成"
