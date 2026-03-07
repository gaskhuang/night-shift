#!/bin/bash
# 🔮 智能推薦引擎
# 分析記憶/討論/日誌，找出值得關注的問題並推薦給用戶
# 執行時間: Round 3 (01:00) - PM 米米負責

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
YESTERDAY=$(date -v-1d '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_DIR="/Users/user/night-shift/logs"
RECOMMENDATION_DIR="/Users/user/night-shift/recommendations"
MEMORY_DIR="/Users/user/memory"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${DATE}.md"

mkdir -p "$RECOMMENDATION_DIR"

RECOMMENDATION_FILE="$RECOMMENDATION_DIR/recommendations_${DATE}.json"
LOG_FILE="$LOG_DIR/night-shift-${DATE}.log"

echo "[$TIME] 🔮 啟動智能推薦引擎..." >> "$LOG_FILE"

# ============================================
# 1. 收集數據源
# ============================================

echo "[$TIME] 📊 收集分析數據..." >> "$LOG_FILE"

# 收集最近3天的記憶
MEMORY_CONTENT=""
for i in 0 1 2; do
    day=$(date -v-${i}d '+%Y-%m-%d')
    if [ -f "$MEMORY_DIR/${day}.md" ]; then
        MEMORY_CONTENT+="\n=== ${day} ===\n"
        MEMORY_CONTENT+=$(cat "$MEMORY_DIR/${day}.md" 2>/dev/null | head -50)
    fi
    # 也檢查 distilled 版本
    if [ -f "$MEMORY_DIR/${day}_Distilled.md" ]; then
        MEMORY_CONTENT+="\n=== ${day} Distilled ===\n"
        MEMORY_CONTENT+=$(cat "$MEMORY_DIR/${day}_Distilled.md" 2>/dev/null | head -30)
    fi
done

# 收集今日討論
DISCUSSION_CONTENT=""
if [ -f "$DISCUSSION" ]; then
    DISCUSSION_CONTENT=$(cat "$DISCUSSION" 2>/dev/null)
fi

# 收集錯誤日誌
ERROR_CONTENT=""
if [ -f "/Users/user/logs/error.log" ]; then
    ERROR_CONTENT=$(tail -50 /Users/user/logs/error.log 2>/dev/null | grep -E "ERROR|WARN|Failed" | tail -20)
fi

# 收集待辦事項 (從 MEMORY.md 或 TASK_LIST.md)
TODO_CONTENT=""
if [ -f "/Users/user/memory/TASK_LIST.md" ]; then
    TODO_CONTENT=$(cat /Users/user/memory/TASK_LIST.md 2>/dev/null | grep -E "^- \[ \|TODO|待辦" | head -20)
elif [ -f "/Users/user/MEMORY.md" ]; then
    TODO_CONTENT=$(grep -A 50 "## 待辦\|## TODO\|## Task" /Users/user/MEMORY.md 2>/dev/null | head -30)
fi

# 收集專案檔案變更 (最近3天修改的檔案)
RECENT_FILES=$(find /Users/user -name "*.md" -mtime -3 -not -path "*/node_modules/*" -not -path "*/.*" -not -path "*/night-shift/*" 2>/dev/null | head -15)

# ============================================
# 2. 分析並生成推薦 (使用本地啟發式規則)
# ============================================

echo "[$TIME] 🧠 分析數據並生成推薦..." >> "$LOG_FILE"

# 初始化推薦陣列
declare -a RECOMMENDATIONS=()
declare -a PRIORITIES=()
declare -a CATEGORIES=()
declare -a CONTEXTS=()

# --- 分析邏輯 1: 檢測重複出現的問題 ---
if echo "$MEMORY_CONTENT" | grep -qi "again\|重複\|又\|還是\|一直"; then
    RECOMMENDATIONS+=("檢測到重複出現的問題模式")
    PRIORITIES+=("high")
    CATEGORIES+=("pattern")
    CONTEXTS+=("記憶檔案中出現重複性問題描述，建議建立自動化處理機制")
fi

# --- 分析邏輯 2: 檢測待辦積壓 ---
TODO_COUNT=$(echo "$TODO_CONTENT" | grep -c "^- \[ \|TODO" || echo 0)
if [ "$TODO_COUNT" -gt 10 ]; then
    RECOMMENDATIONS+=("待辦事項積壓: ${TODO_COUNT} 項未完成")
    PRIORITIES+=("medium")
    CATEGORIES+=("task")
    CONTEXTS+=("待辦清單累積過多，建議優先排序或分解任務")
fi

# --- 分析邏輯 3: 檢測錯誤日誌 ---
ERROR_COUNT=$(echo "$ERROR_CONTENT" | wc -l | tr -d ' ')
if [ "$ERROR_COUNT" -gt 5 ]; then
    RECOMMENDATIONS+=("系統錯誤日誌累積: ${ERROR_COUNT} 條")
    PRIORITIES+=("high")
    CATEGORIES+=("bug")
    CONTEXTS+=("錯誤日誌數量異常，建議進行系統健檢")
fi

# --- 分析邏輯 4: 檢測長期未完成的專案 ---
if echo "$MEMORY_CONTENT" | grep -qi "pending\|卡住\|block\|waiting\|等待"; then
    RECOMMENDATIONS+=("檢測到阻塞中的任務或專案")
    PRIORITIES+=("medium")
    CATEGORIES+=("project")
    CONTEXTS+=("有任務處於等待/阻塞狀態，建議評估是否需要外部協助或調整方向")
fi

# --- 分析邏輯 5: 檢測新機會 ---
if echo "$MEMORY_CONTENT $DISCUSSION_CONTENT" | grep -qi "idea\|想法\|機會\|opportunity\|可以試\|值得做"; then
    RECOMMENDATIONS+=("發現潛在新機會或想法")
    PRIORITIES+=("low")
    CATEGORIES+=("opportunity")
    CONTEXTS+=("記錄中有新的想法或機會，建議進一步評估可行性")
fi

# --- 分析邏輯 6: 檔案/知識整理需求 ---
MEMORY_FILE_COUNT=$(find "$MEMORY_DIR" -name "*.md" | wc -l | tr -d ' ')
if [ "$MEMORY_FILE_COUNT" -gt 50 ]; then
    RECOMMENDATIONS+=("記憶檔案累積: ${MEMORY_FILE_COUNT} 個，建議整理")
    PRIORITIES+=("low")
    CATEGORIES+=("maintenance")
    CONTEXTS+=("記憶檔案數量較多，建議進行歸檔或建立索引")
fi

# --- 分析邏輯 7: 檢測需要決策的事項 ---
if echo "$MEMORY_CONTENT $DISCUSSION_CONTENT" | grep -qi "?\|問\|如何\|怎麼\|是否\|要不要"; then
    QUESTIONS=$(echo "$MEMORY_CONTENT $DISCUSSION_CONTENT" | grep -E "\?|如何|怎麼|是否|要不要" | head -5)
    if [ -n "$QUESTIONS" ]; then
        RECOMMENDATIONS+=("檢測到未回答的問題需要決策")
        PRIORITIES+=("medium")
        CATEGORIES+=("decision")
        CONTEXTS+=("記錄中有待決策的問題，建議排時間思考或討論")
    fi
fi

# --- 分析邏輯 8: 檢測學習/研究需求 ---
if echo "$MEMORY_CONTENT" | grep -qi "學習\|研究\|不懂\|查詢\|search\|learn\|tutorial"; then
    RECOMMENDATIONS+=("發現學習或研究需求")
    PRIORITIES+=("low")
    CATEGORIES+=("learning")
    CONTEXTS+=("有需要學習的新技術或研究主題，可安排在低峰時段進行")
fi

# ============================================
# 3. 如果沒有檢測到明顯問題，給出預設推薦
# ============================================

if [ ${#RECOMMENDATIONS[@]} -eq 0 ]; then
    RECOMMENDATIONS+=("系統運作良好，建議進行預防性維護")
    PRIORITIES+=("low")
    CATEGORIES+=("maintenance")
    CONTEXTS+=("目前無明顯問題，建議回顧本週目標進度，或進行技能升級")
fi

# ============================================
# 4. 生成 JSON 格式的推薦文件
# ============================================

echo "[$TIME] 📝 生成推薦文件..." >> "$LOG_FILE"

# 構建 JSON
JSON_CONTENT="{\n"
JSON_CONTENT+="  \"date\": \"${DATE}\",\n"
JSON_CONTENT+="  \"generated_at\": \"${TIME}\",\n"
JSON_CONTENT+="  \"total_recommendations\": ${#RECOMMENDATIONS[@]},\n"
JSON_CONTENT+="  \"recommendations\": [\n"

for i in "${!RECOMMENDATIONS[@]}"; do
    JSON_CONTENT+="    {\n"
    JSON_CONTENT+="      \"id\": \"rec_${DATE}_${i}\",\n"
    JSON_CONTENT+="      \"title\": \"${RECOMMENDATIONS[$i]}\",\n"
    JSON_CONTENT+="      \"priority\": \"${PRIORITIES[$i]}\",\n"
    JSON_CONTENT+="      \"category\": \"${CATEGORIES[$i]}\",\n"
    JSON_CONTENT+="      \"context\": \"${CONTEXTS[$i]}\",\n"
    JSON_CONTENT+="      \"status\": \"pending\",\n"
    JSON_CONTENT+="      \"solution\": null\n"
    if [ $i -lt $((${#RECOMMENDATIONS[@]} - 1)) ]; then
        JSON_CONTENT+="    },\n"
    else
        JSON_CONTENT+="    }\n"
    fi
done

JSON_CONTENT+="  ],\n"
JSON_CONTENT+="  \"data_sources\": {\n"
JSON_CONTENT+="    \"memory_files_analyzed\": $(echo "$MEMORY_CONTENT" | grep -c "===" || echo 0),\n"
JSON_CONTENT+="    \"todo_items_found\": $TODO_COUNT,\n"
JSON_CONTENT+="    \"error_logs_found\": $ERROR_COUNT,\n"
JSON_CONTENT+="    \"recent_files\": $(echo "$RECENT_FILES" | wc -l | tr -d ' ')\n"
JSON_CONTENT+="  }\n"
JSON_CONTENT+="}"

# 寫入文件
echo -e "$JSON_CONTENT" > "$RECOMMENDATION_FILE"

# ============================================
# 5. 記錄到討論區
# ============================================

echo "" >> "$DISCUSSION"
echo "### 🔮 米米 (推薦引擎):" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"
echo "完成智能分析，發現 **${#RECOMMENDATIONS[@]}** 個推薦事項：" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

for i in "${!RECOMMENDATIONS[@]}"; do
    PRIORITY_EMOJI="🟢"
    if [ "${PRIORITIES[$i]}" = "high" ]; then
        PRIORITY_EMOJI="🔴"
    elif [ "${PRIORITIES[$i]}" = "medium" ]; then
        PRIORITY_EMOJI="🟡"
    fi
    echo "${PRIORITY_EMOJI} **${RECOMMENDATIONS[$i]}** (${PRIORITIES[$i]})" >> "$DISCUSSION"
    echo "   > ${CONTEXTS[$i]}" >> "$DISCUSSION"
    echo "" >> "$DISCUSSION"
done

echo "📄 詳細報告: \`$RECOMMENDATION_FILE\`" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

echo "[$TIME] ✅ 推薦引擎完成，生成 ${#RECOMMENDATIONS[@]} 條推薦" >> "$LOG_FILE"
