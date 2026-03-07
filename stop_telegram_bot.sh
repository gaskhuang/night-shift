#!/bin/bash
# 🛑 停止 Telegram Bot

PID_FILE="/tmp/night-shift-telegram-bot.pid"

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "🛑 正在停止 Telegram Bot (PID: $PID)..."
        kill "$PID"
        sleep 2
        
        # 檢查是否還在執行
        if ps -p "$PID" > /dev/null 2>&1; then
            echo "⚠️ 強制停止..."
            kill -9 "$PID"
        fi
        
        rm -f "$PID_FILE"
        echo "✅ Telegram Bot 已停止"
    else
        echo "⚠️ Bot 已不在執行"
        rm -f "$PID_FILE"
    fi
else
    echo "⚠️ 找不到 PID 檔案，Bot 可能未在執行"
    
    # 嘗試尋找並停止
    PIDS=$(pgrep -f "telegram_bot.py" || true)
    if [ -n "$PIDS" ]; then
        echo "🔍 找到相關進程，正在停止..."
        echo "$PIDS" | xargs kill -9
        echo "✅ 已停止"
    fi
fi
