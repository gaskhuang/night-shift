#!/bin/bash
# 🎯 下一步行動推薦引擎 Wrapper
# 每天早上 08:30 執行，生成今日行動推薦

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
export HOME="/Users/user"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_DIR="/Users/user/night-shift/logs"
LOG_FILE="$LOG_DIR/next-action-${DATE}.log"
DAILY_DIR="/Users/user/night-shift/daily-iteration"

mkdir -p "$LOG_DIR"

echo "[$TIME] 🎯 啟動下一步行動推薦引擎..." >> "$LOG_FILE"

# 執行 Python 腳本
if [ -f "$DAILY_DIR/next_action_engine.py" ]; then
    python3 "$DAILY_DIR/next_action_engine.py" --morning --telegram >> "$LOG_FILE" 2>&1
    echo "[$TIME] ✅ 推薦生成完成" >> "$LOG_FILE"
else
    echo "[$TIME] ❌ 找不到 next_action_engine.py" >> "$LOG_FILE"
    exit 1
fi

# 如果有 Telegram bot，發送通知
TELEGRAM_MSG_FILE="$DAILY_DIR/telegram_message.txt"
if [ -f "$TELEGRAM_MSG_FILE" ]; then
    echo "[$TIME] 📱 Telegram 訊息已準備" >> "$LOG_FILE"
    # 這裡可以添加發送 Telegram 訊息的邏輯
fi

echo "[$TIME] 📄 推薦報告位置: $DAILY_DIR/recommendation.md" >> "$LOG_FILE"
