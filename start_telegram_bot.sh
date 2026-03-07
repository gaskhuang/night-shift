#!/bin/bash
# 🌙 夜班系統 Telegram Bot 啟動腳本

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"

BOT_DIR="/Users/user/night-shift"
PID_FILE="/tmp/night-shift-telegram-bot.pid"
LOG_DIR="$BOT_DIR/logs"
LOG_FILE="$LOG_DIR/telegram-bot.log"

# 確保目錄存在
mkdir -p "$LOG_DIR"

# 檢查是否已在執行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "⚠️ Telegram Bot 已在執行中 (PID: $OLD_PID)"
        echo "若要重新啟動，請先執行: ./stop_telegram_bot.sh"
        exit 0
    fi
fi

# 檢查虛擬環境
VENV_PATH="$HOME/.venv_telegram_bot"
if [ ! -d "$VENV_PATH" ]; then
    echo "🔧 創建虛擬環境..."
    python3 -m venv "$VENV_PATH"
fi

# 啟用虛擬環境
source "$VENV_PATH/bin/activate"

# 檢查並安裝依賴
echo "📦 檢查依賴..."
pip install -q python-telegram-bot openai 2>/dev/null || true

# 設定環境變數
export TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN:-}"
export TELEGRAM_ALLOWED_USER_ID="${TELEGRAM_ALLOWED_USER_ID:-7132792298}"
export OPENAI_API_KEY="${OPENAI_API_KEY:-}"

# 啟動 Bot
echo "🚀 啟動 Telegram Bot..."
cd "$BOT_DIR"

# 在背景執行並記錄 PID
python3 "$BOT_DIR/telegram_bot.py" >> "$LOG_FILE" 2>&1 &
PID=$!
echo $PID > "$PID_FILE"

echo "✅ Telegram Bot 已啟動 (PID: $PID)"
echo "📋 日誌檔案: $LOG_FILE"
echo ""
echo "控制指令:"
echo "  停止: ./stop_telegram_bot.sh"
echo "  查看日誌: tail -f $LOG_FILE"
echo "  查看狀態: ./status_telegram_bot.sh"
