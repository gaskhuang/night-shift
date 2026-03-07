#!/bin/bash
# 🌙 夜班系統 + Telegram Bot 整合啟動腳本

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"
export HOME="/Users/user"

echo "🌙 AI 夜班系統 v2.5 - 整合啟動"
echo "================================"
echo ""

# 顏色輸出
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

NIGHT_SHIFT_DIR="/Users/user/night-shift"

# ============================================
# 1. 檢查環境
# ============================================
echo -e "${BLUE}🔍 檢查環境...${NC}"

# 檢查 Python
if ! command -v python3 &> /dev/null; then
    echo "❌ 找不到 python3，請先安裝"
    exit 1
fi

# 檢查必要套件
if ! python3 -c "import telegram" 2>/dev/null; then
    echo "⚠️  正在安裝 python-telegram-bot..."
    pip3 install python-telegram-bot --quiet
fi

echo -e "${GREEN}✅ 環境檢查通過${NC}"
echo ""

# ============================================
# 2. 設定 Cron
# ============================================
echo -e "${BLUE}📅 設定 Cron 排程...${NC}"

if crontab -l 2>/dev/null | grep -q "night-shift"; then
    echo "ℹ️  Cron 已設定，跳過"
else
    bash "$NIGHT_SHIFT_DIR/setup_cron_v2.sh"
fi

echo -e "${GREEN}✅ Cron 設定完成${NC}"
echo ""

# ============================================
# 3. 啟動 Telegram Bot
# ============================================
echo -e "${BLUE}🤖 啟動 Telegram Bot...${NC}"

# 檢查是否已在執行
if pgrep -f "telegram_bot.py" > /dev/null; then
    echo "ℹ️  Telegram Bot 已在執行中"
else
    # 背景啟動 Bot
    nohup python3 "$NIGHT_SHIFT_DIR/telegram_bot.py" > "$NIGHT_SHIFT_DIR/logs/telegram_bot.log" 2>&1 &
    sleep 2
    
    if pgrep -f "telegram_bot.py" > /dev/null; then
        echo -e "${GREEN}✅ Telegram Bot 已啟動${NC}"
        
        # 設定選單
        echo "📝 設定 Bot 選單..."
        python3 "$NIGHT_SHIFT_DIR/setup_bot_menu.py" > /dev/null 2>&1 || true
    else
        echo -e "${YELLOW}⚠️  Telegram Bot 啟動失敗，請檢查日誌${NC}"
    fi
fi

echo ""

# ============================================
# 4. 測試推薦引擎
# ============================================
echo -e "${BLUE}🎯 測試推薦引擎...${NC}"

if [ -f "$NIGHT_SHIFT_DIR/daily-iteration/next_action_engine.py" ]; then
    python3 "$NIGHT_SHIFT_DIR/daily-iteration/next_action_engine.py" --today > /dev/null 2>&1 || true
    echo -e "${GREEN}✅ 推薦引擎測試完成${NC}"
else
    echo -e "${YELLOW}⚠️  找不到推薦引擎${NC}"
fi

echo ""

# ============================================
# 5. 顯示狀態
# ============================================
echo -e "${GREEN}🎉 系統啟動完成！${NC}"
echo ""
echo "═══════════════════════════════════════════════════"
echo "  📱 Telegram Bot: 已啟動"
echo "  ⏰ Cron 排程: 已設定 (每20分鐘)"
echo "  🎯 推薦引擎: 已就緒 (每天 08:30)"
echo "═══════════════════════════════════════════════════"
echo ""
echo "Telegram 指令:"
echo "  /start     - 顯示主選單"
echo "  /optimize  - 🔧 系統優化"
echo "  /recommend - 🧠 第二大腦推薦"
echo "  /think     - 💭 思考模式 (GPT-5.4)"
echo "  /status    - 📊 查看狀態"
echo ""
echo "手動操作:"
echo "  啟動夜班:  $NIGHT_SHIFT_DIR/orchestrator_v2.sh"
echo "  查看推薦:  cat $NIGHT_SHIFT_DIR/daily-iteration/recommendation.md"
echo "  查看日誌:  tail -f $NIGHT_SHIFT_DIR/logs/cron.log"
echo ""
echo "═══════════════════════════════════════════════════"
