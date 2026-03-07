#!/bin/bash
# 🧪 Telegram Bot 測試腳本

set -e

export HOME="/Users/user"
VENV_PATH="$HOME/.venv_telegram_bot"
CREDENTIALS_DIR="$HOME/.openclaw/credentials"

echo "🧪 Telegram Bot 測試程序"
echo "========================"
echo ""

# 1. 檢查虛擬環境
echo "1️⃣ 檢查虛擬環境..."
if [ -d "$VENV_PATH" ]; then
    echo "   ✅ 虛擬環境已存在"
else
    echo "   ❌ 虛擬環境不存在，請先執行 ./install_telegram_bot.sh"
    exit 1
fi

# 2. 檢查依賴
echo ""
echo "2️⃣ 檢查 Python 依賴..."
source "$VENV_PATH/bin/activate"

python3 -c "import telegram" 2>/dev/null && echo "   ✅ python-telegram-bot 已安裝" || echo "   ❌ python-telegram-bot 未安裝"
python3 -c "import openai" 2>/dev/null && echo "   ✅ openai 已安裝" || echo "   ❌ openai 未安裝"

# 3. 檢查憑證
echo ""
echo "3️⃣ 檢查憑證設定..."

if [ -f "$CREDENTIALS_DIR/telegram_bot_token" ]; then
    TOKEN=$(cat "$CREDENTIALS_DIR/telegram_bot_token")
    if [ -n "$TOKEN" ]; then
        echo "   ✅ Telegram Bot Token 已設定"
        echo "   📋 Token 長度: ${#TOKEN} 字元"
    else
        echo "   ❌ Telegram Bot Token 為空"
    fi
else
    echo "   ❌ Telegram Bot Token 檔案不存在"
fi

if [ -f "$CREDENTIALS_DIR/openai.key" ]; then
    KEY=$(cat "$CREDENTIALS_DIR/openai.key")
    if [ -n "$KEY" ]; then
        echo "   ✅ OpenAI API Key 已設定"
        echo "   📋 Key 長度: ${#KEY} 字元"
    else
        echo "   ⚠️ OpenAI API Key 為空（思考模式將無法使用）"
    fi
else
    echo "   ⚠️ OpenAI API Key 檔案不存在（思考模式將無法使用）"
fi

if [ -f "$CREDENTIALS_DIR/telegram_allowed_user_id" ]; then
    USER_ID=$(cat "$CREDENTIALS_DIR/telegram_allowed_user_id")
    echo "   ✅ 允許的使用者 ID: $USER_ID"
else
    echo "   ⚠️ 使用者 ID 未設定（將允許所有使用者）"
fi

# 4. 檢查 Bot 檔案
echo ""
echo "4️⃣ 檢查 Bot 檔案..."

BOT_FILES=(
    "/Users/user/night-shift/telegram_bot.py"
    "/Users/user/night-shift/start_telegram_bot.sh"
    "/Users/user/night-shift/stop_telegram_bot.sh"
)

for file in "${BOT_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✅ $(basename $file)"
    else
        echo "   ❌ $(basename $file) 不存在"
    fi
done

# 5. 檢查執行權限
echo ""
echo "5️⃣ 檢查執行權限..."

for file in "${BOT_FILES[@]}"; do
    if [ -x "$file" ]; then
        echo "   ✅ $(basename $file) 可執行"
    else
        echo "   ⚠️ $(basename $file) 需要執行權限"
    fi
done

# 6. 測試 Python 語法
echo ""
echo "6️⃣ 測試 Python 語法..."

if python3 -m py_compile /Users/user/night-shift/telegram_bot.py 2>/dev/null; then
    echo "   ✅ telegram_bot.py 語法正確"
else
    echo "   ❌ telegram_bot.py 語法錯誤"
fi

# 7. 檢查 Bot 執行狀態
echo ""
echo "7️⃣ 檢查 Bot 執行狀態..."

PID_FILE="/tmp/night-shift-telegram-bot.pid"
if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    if ps -p "$PID" > /dev/null 2>&1; then
        echo "   🟢 Bot 正在執行 (PID: $PID)"
    else
        echo "   ⚪ Bot 未在執行 (PID 檔案過期)"
    fi
else
    echo "   ⚪ Bot 未在執行"
fi

echo ""
echo "========================"
echo "✅ 測試完成！"
echo ""
echo "下一步："
echo "  1. 如果憑證未設定，執行 ./install_telegram_bot.sh"
echo "  2. 啟動 Bot: ./start_telegram_bot.sh"
echo "  3. 設定選單: python3 setup_bot_menu.py"
