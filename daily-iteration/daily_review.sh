#!/bin/bash
# 🌆 每日覆盤腳本 - Daily Evening Review
# 執行時間: 每天 22:00 或手動觸發
# 功能: 引導 G大 完成每日覆盤，記錄成果與明日意圖

set -e

REVIEW_DIR="/Users/user/night-shift/evening"
MEMORY_DIR="/Users/user/memory"
DATE=$(date +%Y-%m-%d)
REVIEW_FILE="$REVIEW_DIR/${DATE}_Evening.md"

# 顏色定義
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║              🌆 DAILY EVENING REVIEW                       ║"
echo "║                   每日覆盤時間                              ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo "今天過得如何？讓我們花 5 分鐘回顧一下。"
echo ""

# 確保目錄存在
mkdir -p "$REVIEW_DIR"

# 讀取今天的記憶檔案（如果存在）
TODAY_MEMORY="$MEMORY_DIR/${DATE}.md"
if [ -f "$TODAY_MEMORY" ]; then
    echo -e "${GREEN}📖 今日記憶檔已找到${NC}"
    echo ""
else
    echo -e "${YELLOW}⚠️  今日記憶檔尚未建立，將從頭開始${NC}"
    echo ""
fi

# 建立覆盤檔案
cat > "$REVIEW_FILE" << EOF
# 🌆 每日覆盤 - $DATE

## ⏰ 覆盤時間
$(date '+%Y-%m-%d %H:%M %Z')

---

## ✅ 今日完成 (Done)
<!-- 列出今天完成的主要事項 -->
- [ ] 
- [ ] 
- [ ] 

## 📊 今日數據
| 指標 | 數值 | 備註 |
|------|------|------|
| 完成任務數 | X | |
| 專注時長 | X 小時 | |
| 能量水平 (1-10) | X | 1=累癱, 10=充滿電 |
| 滿意度 (1-10) | X | 對今天的整體滿意度 |

## 💡 今日洞察
### 新機會
<!-- 今天發現什麼新機會？ -->

### 教訓/反思
<!-- 今天學到什麼？有什麼可以做得更好？ -->

### 意外收穫
<!-- 有什麼意料之外的好事？ -->

---

## 🎯 明日意圖 (Tomorrow Intent)

### 如果明天只能做一件事，那會是：
**_________**

### 期望能量狀態
- [ ] 高能量 (適合創造/深度工作)
- [ ] 中能量 (適合協作/執行)
- [ ] 低能量 (適合整理/維護)

### 期望專注時段
- [ ] 上午 (09:00-12:00)
- [ ] 下午 (14:00-17:00)
- [ ] 晚上 (20:00-22:00)

---

## 🔥 待孵化想法
<!-- 今天想到但沒時間深入的想法 -->
1. 
2. 
3. 

---

## 📝 其他筆記

EOF

echo -e "${GREEN}✅ 覆盤範本已建立: $REVIEW_FILE${NC}"
echo ""
echo -e "${YELLOW}💡 請打開檔案，花 5 分鐘填寫:${NC}"
echo "   $REVIEW_FILE"
echo ""

# 嘗試用預設編輯器開啟 (macOS)
if command -v open &> /dev/null; then
    open "$REVIEW_FILE" 2>/dev/null || true
fi

# 更新任務狀態 (如果從 TASK_LIST.md 同步)
TASK_LIST="/Users/user/memory/TASK_LIST.md"
if [ -f "$TASK_LIST" ]; then
    echo -e "${BLUE}📋 提醒: 記得更新 TASK_LIST.md 中的任務狀態${NC}"
    echo "   $TASK_LIST"
    echo ""
fi

echo -e "${GREEN}🌙 覆盤完成後，夜班系統將基於你的輸入調整明日任務優先級${NC}"
echo ""
echo "明天見！晚安 🌙"
