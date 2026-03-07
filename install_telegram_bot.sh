#!/bin/bash
# 🔧 Telegram Bot 安裝腳本

set -e

export HOME="/Users/user"
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

BOT_DIR="/Users/user/night-shift"
VENV_PATH="$HOME/.venv_telegram_bot"
CREDENTIALS_DIR="$HOME/.openclaw/credentials"

echo "🌙 夜班系統 Telegram Bot 安裝程序"
echo "=================================="
echo ""

# 1. 檢查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 錯誤：找不到 Python3"
    echo "請先安裝 Python 3.9+"
    exit 1
fi

echo "✅ Python3 已安裝: $(python3 --version)"

# 2. 創建虛擬環境
echo ""
echo "🔧 步驟 1: 創建虛擬環境..."
if [ ! -d "$VENV_PATH" ]; then
    python3 -m venv "$VENV_PATH"
    echo "✅ 虛擬環境創建完成"
else
    echo "✅ 虛擬環境已存在"
fi

# 3. 安裝依賴
echo ""
echo "🔧 步驟 2: 安裝依賴..."
source "$VENV_PATH/bin/activate"
pip install --upgrade pip -q
pip install python-telegram-bot openai -q
echo "✅ 依賴安裝完成"

# 4. 建立憑證目錄
echo ""
echo "🔧 步驟 3: 設定憑證..."
mkdir -p "$CREDENTIALS_DIR"

# 5. 設定 Telegram Bot Token
echo ""
echo "📱 Telegram Bot 設定"
echo "--------------------"

if [ -f "$CREDENTIALS_DIR/telegram_bot_token" ]; then
    echo "✅ Telegram Bot Token 已設定"
else
    echo "請輸入您的 Telegram Bot Token:"
    echo "(從 @BotFather 獲取，格式如: 123456789:ABCdefGHIjklMNOpqrsTUVwxyz)"
    read -s TELEGRAM_TOKEN
    
    if [ -n "$TELEGRAM_TOKEN" ]; then
        echo "$TELEGRAM_TOKEN" > "$CREDENTIALS_DIR/telegram_bot_token"
        chmod 600 "$CREDENTIALS_DIR/telegram_bot_token"
        echo "✅ Telegram Bot Token 已儲存"
    else
        echo "⚠️ 未輸入 Token，請稍後手動設定"
    fi
fi

# 6. 設定 OpenAI API Key
echo ""
echo "🤖 OpenAI API 設定"
echo "------------------"

if [ -f "$CREDENTIALS_DIR/openai.key" ]; then
    echo "✅ OpenAI API Key 已設定"
else
    echo "請輸入您的 OpenAI API Key:"
    echo "(用於思考模式，格式如: sk-...)"
    read -s OPENAI_KEY
    
    if [ -n "$OPENAI_KEY" ]; then
        echo "$OPENAI_KEY" > "$CREDENTIALS_DIR/openai.key"
        chmod 600 "$CREDENTIALS_DIR/openai.key"
        echo "✅ OpenAI API Key 已儲存"
    else
        echo "⚠️ 未輸入 API Key，思考模式將無法使用"
    fi
fi

# 7. 設定允許的使用者 ID
echo ""
echo "👤 使用者權限設定"
echo "-----------------"

if [ -f "$CREDENTIALS_DIR/telegram_allowed_user_id" ]; then
    echo "✅ 使用者 ID 已設定: $(cat $CREDENTIALS_DIR/telegram_allowed_user_id)"
else
    echo "請輸入您的 Telegram User ID (預設: 7132792298):"
    read USER_ID
    USER_ID=${USER_ID:-"7132792298"}
    echo "$USER_ID" > "$CREDENTIALS_DIR/telegram_allowed_user_id"
    echo "✅ 使用者 ID 已設定: $USER_ID"
fi

# 8. 設定檔案權限
chmod +x "$BOT_DIR/start_telegram_bot.sh"
chmod +x "$BOT_DIR/stop_telegram_bot.sh"
chmod +x "$BOT_DIR/status_telegram_bot.sh"
chmod +x "$BOT_DIR/telegram_bot.py"

# 9. 建立快捷指令
echo ""
echo "🔧 步驟 4: 建立快捷指令..."

# 添加到 .zshrc
SHELL_RC="$HOME/.zshrc"
if ! grep -q "night-shift-bot" "$SHELL_RC" 2>/dev/null; then
    echo "" >> "$SHELL_RC"
    echo "# Night Shift Telegram Bot Aliases" >> "$SHELL_RC"
    echo "alias ns-bot-start='cd $BOT_DIR && ./start_telegram_bot.sh'" >> "$SHELL_RC"
    echo "alias ns-bot-stop='cd $BOT_DIR && ./stop_telegram_bot.sh'" >> "$SHELL_RC"
    echo "alias ns-bot-status='cd $BOT_DIR && ./status_telegram_bot.sh'" >> "$SHELL_RC"
    echo "alias ns-bot-log='tail -f $BOT_DIR/logs/telegram-bot.log'" >> "$SHELL_RC"
    echo "✅ 快捷指令已添加到 .zshrc"
else
    echo "✅ 快捷指令已存在"
fi

echo ""
echo "=================================="
echo "✅ 安裝完成！"
echo ""
echo "使用方法:"
echo "--------"
echo "啟動 Bot:     ./start_telegram_bot.sh"
echo "停止 Bot:     ./stop_telegram_bot.sh"
echo "查看狀態:     ./status_telegram_bot.sh"
echo "查看日誌:     tail -f logs/telegram-bot.log"
echo ""
echo "快捷指令 (重開終端後可用):"
echo "  ns-bot-start   - 啟動 Bot"
echo "  ns-bot-stop    - 停止 Bot"
echo "  ns-bot-status  - 查看狀態"
echo "  ns-bot-log     - 查看日誌"
echo ""
echo "Telegram 指令選單:"
echo "  /start      - 顯示主選單"
echo "  /optimize   - 系統優化"
echo "  /recommend  - 第二大腦推薦"
echo "  /think      - 思考模式"
echo "  /status     - 查看狀態"
echo "  /help       - 使用說明"
echo ""
echo "現在可以啟動 Bot: ./start_telegram_bot.sh"
