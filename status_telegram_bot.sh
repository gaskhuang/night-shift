#!/bin/bash
# 📊 Telegram Bot 狀態檢查

PID_FILE="/tmp/night-shift-telegram-bot.pid"
LOG_FILE="/Users/user/night-shift/logs/telegram-bot.log"

echo "📊 Telegram Bot 狀態"
echo "===================="

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "🟢 狀態: 執行中"
        echo "🆔 PID: $PID"
        echo "⏱️  執行時間: $(ps -o etime= -p $PID)"
    else
        echo "🔴 狀態: 未執行 (PID 檔案過期)"
    fi
else
    echo "🔴 狀態: 未執行"
fi

echo ""
echo "📋 最近日誌:"
if [ -f "$LOG_FILE" ]; then
    tail -20 "$LOG_FILE"
else
    echo "無日誌檔案"
fi
