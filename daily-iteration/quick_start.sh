#!/bin/bash
# 🚀 每日迭代系統 - 快速啟動

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NIGHT_SHIFT_DIR="$(dirname "$SCRIPT_DIR")"

# 顏色
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}"
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║        🔄 DAILY ITERATION SYSTEM | 每日迭代系統               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""

# 顯示選單
echo -e "${BLUE}請選擇要執行的操作:${NC}"
echo ""
echo "  ${GREEN}1${NC}) 🌅  獲取今日行動推薦"
echo "  ${GREEN}2${NC}) 🌆  執行每日覆盤"
echo "  ${GREEN}3${NC}) 📅  查看本週規劃"
echo "  ${GREEN}4${NC}) 🗓️   查看本月規劃"
echo "  ${GREEN}5${NC}) ⚡  快速任務推薦 (低能量)"
echo "  ${GREEN}6${NC}) 🚀  高能量任務推薦"
echo "  ${GREEN}7${NC}) 📊  查看系統狀態"
echo "  ${GREEN}0${NC}) ❌  離開"
echo ""

read -p "請輸入選項 (0-7): " choice

case $choice in
    1)
        echo ""
        echo -e "${BLUE}🌅 正在生成今日行動推薦...${NC}"
        echo ""
        python3 "$SCRIPT_DIR/next_action_engine.py" --today
        echo ""
        read -p "按 Enter 鍵開啟推薦文件..."
        open "$SCRIPT_DIR/recommendation.md" 2>/dev/null || cat "$SCRIPT_DIR/recommendation.md"
        ;;
    2)
        echo ""
        "$SCRIPT_DIR/daily_review.sh"
        ;;
    3)
        WEEK_FILE="$NIGHT_SHIFT_DIR/planning/WEEK-$(date +%V).md"
        if [ ! -f "$WEEK_FILE" ]; then
            cp "$NIGHT_SHIFT_DIR/planning/WEEK-TEMPLATE.md" "$WEEK_FILE"
            echo -e "${GREEN}✅ 已建立本週規劃文件${NC}"
        fi
        echo -e "${BLUE}📅 開啟本週規劃...${NC}"
        open "$WEEK_FILE" 2>/dev/null || cat "$WEEK_FILE"
        ;;
    4)
        MONTH_FILE="$NIGHT_SHIFT_DIR/planning/MONTH-$(date +%Y-%m).md"
        if [ ! -f "$MONTH_FILE" ]; then
            cp "$NIGHT_SHIFT_DIR/planning/MONTH-TEMPLATE.md" "$MONTH_FILE"
            echo -e "${GREEN}✅ 已建立本月規劃文件${NC}"
        fi
        echo -e "${BLUE}🗓️  開啟本月規劃...${NC}"
        open "$MONTH_FILE" 2>/dev/null || cat "$MONTH_FILE"
        ;;
    5)
        echo ""
        echo -e "${BLUE}⚡ 低能量任務推薦...${NC}"
        python3 "$SCRIPT_DIR/next_action_engine.py" --energy low
        ;;
    6)
        echo ""
        echo -e "${BLUE}🚀 高能量任務推薦...${NC}"
        python3 "$SCRIPT_DIR/next_action_engine.py" --energy high
        ;;
    7)
        echo ""
        echo -e "${BLUE}📊 系統狀態${NC}"
        echo ""
        echo "📁 記憶檔案:"
        ls -1t "$NIGHT_SHIFT_DIR/evening"/*Evening.md 2>/dev/null | head -3 || echo "  (尚無覆盤記錄)"
        echo ""
        echo "📋 待辦任務:"
        grep -c "^\- \[ \]" /Users/user/memory/TASK_LIST.md 2>/dev/null || echo "  0"
        echo ""
        echo "📰 最近晨報:"
        ls -1t "$NIGHT_SHIFT_DIR/reports"/morning-report*.md 2>/dev/null | head -1 | xargs basename 2>/dev/null || echo "  (尚無晨報)"
        ;;
    0)
        echo -e "${YELLOW}👋 再見！${NC}"
        exit 0
        ;;
    *)
        echo -e "${YELLOW}⚠️  無效選項${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✨ 完成！${NC}"
