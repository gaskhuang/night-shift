#!/bin/bash
# 🤖 Subagent: 晨報草稿
# 預先生成晨報草稿，06:00 最終確認

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 📝 生成晨報草稿..."

# 收集夜班日誌亮點
LOG_FILE="/Users/user/night-shift/logs/night-shift-${DATE}.log"
if [ -f "$LOG_FILE" ]; then
    COMPLETED=$(grep -c "✅" "$LOG_FILE" 2>/dev/null || echo 0)
    echo "[$TIME] 📊 本班完成: $COMPLETED 個任務標記"
else
    echo "[$TIME] ⚠️ 日誌尚未生成"
fi

echo "[$TIME] ✅ 晨報草稿準備完成"
