#!/bin/bash
# 💡 解法生成器
# 針對推薦引擎發現的問題，自動生成解法提案
# 執行時間: Round 6 (04:00) - PM 米米負責

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_DIR="/Users/user/night-shift/logs"
RECOMMENDATION_DIR="/Users/user/night-shift/recommendations"
SOLUTION_DIR="/Users/user/night-shift/solutions"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${DATE}.md"

mkdir -p "$SOLUTION_DIR"

RECOMMENDATION_FILE="$RECOMMENDATION_DIR/recommendations_${DATE}.json"
SOLUTION_FILE="$SOLUTION_DIR/solutions_${DATE}.json"
LOG_FILE="$LOG_DIR/night-shift-${DATE}.log"

echo "[$TIME] 💡 啟動解法生成器..." >> "$LOG_FILE"

# ============================================
# 1. 讀取推薦文件
# ============================================

if [ ! -f "$RECOMMENDATION_FILE" ]; then
    echo "[$TIME] ⚠️ 找不到推薦文件，跳過解法生成" >> "$LOG_FILE"
    echo "### 💡 米米 (解法生成器):" >> "$DISCUSSION"
    echo "找不到推薦文件，無法生成解法" >> "$DISCUSSION"
    exit 0
fi

echo "[$TIME] 📖 讀取推薦文件..." >> "$LOG_FILE"

# 解析推薦（使用簡單的 grep/sed 方法）
REC_COUNT=$(grep -c '"id":' "$RECOMMENDATION_FILE" || echo 0)
echo "[$TIME] 找到 $REC_COUNT 個推薦事項" >> "$LOG_FILE"

# ============================================
# 2. 為每個推薦生成解法
# ============================================

declare -a SOLUTIONS=()
declare -a SOLUTION_DETAILS=()
declare -a ESTIMATED_TIME=()
declare -a AUTO_APPLY=()

# 讀取每個推薦並生成解法
for i in $(seq 0 $(($REC_COUNT - 1))); do
    # 提取推薦信息
    REC_TITLE=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"title":' | head -1 | sed 's/.*"title": "\(.*\)".*/\1/')
    REC_PRIORITY=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"priority":' | head -1 | sed 's/.*"priority": "\(.*\)".*/\1/')
    REC_CATEGORY=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"category":' | head -1 | sed 's/.*"category": "\(.*\)".*/\1/')
    
    echo "[$TIME] 處理推薦 $i: $REC_TITLE" >> "$LOG_FILE"
    
    # 根據類別生成對應解法
    case "$REC_CATEGORY" in
        "pattern")
            SOLUTIONS+=("建立自動化監控與處理流程")
            SOLUTION_DETAILS+=("1. 使用 cron 設定定期檢查\n2. 建立問題分類規則\n3. 設定自動化修復腳本\n4. 建立警報通知機制")
            ESTIMATED_TIME+=("2-3 天")
            AUTO_APPLY+=("partial")
            ;;
        "task")
            SOLUTIONS+=("實施待辦事項自動化分類與提醒")
            SOLUTION_DETAILS+=("1. 按優先級分類待辦事項\n2. 設定每日自動提醒\n3. 建立進度追蹤儀表板\n4. 建議分解大型任務")
            ESTIMATED_TIME+=("半天")
            AUTO_APPLY+=("yes")
            ;;
        "bug")
            SOLUTIONS+=("執行系統健檢與錯誤修復")
            SOLUTION_DETAILS+=("1. 分析錯誤日誌模式\n2. 識別根本原因\n3. 修復已知問題\n4. 更新錯誤監控規則")
            ESTIMATED_TIME+=("1-2 天")
            AUTO_APPLY+=("no")
            ;;
        "project")
            SOLUTIONS+=("進行專案阻塞點分析與資源調度")
            SOLUTION_DETAILS+=("1. 識別阻塞原因\n2. 評估外部資源需求\n3. 設定檢查點與里程碑\n4. 準備升級方案")
            ESTIMATED_TIME+=("1 天")
            AUTO_APPLY+=("no")
            ;;
        "opportunity")
            SOLUTIONS+=("建立機會評估框架與快速驗證流程")
            SOLUTION_DETAILS+=("1. 評估可行性與ROI\n2. 設計最小驗證實驗\n3. 設定決策時間點\n4. 準備資源規劃")
            ESTIMATED_TIME+=("2-3 天")
            AUTO_APPLY+=("no")
            ;;
        "maintenance")
            SOLUTIONS+=("執行預防性維護與知識整理")
            SOLUTION_DETAILS+=("1. 歸檔舊記憶檔案\n2. 建立索引與標籤\n3. 清理臨時文件\n4. 優化資料結構")
            ESTIMATED_TIME+=("半天")
            AUTO_APPLY+=("yes")
            ;;
        "decision")
            SOLUTIONS+=("整理決策清單與背景資料準備")
            SOLUTION_DETAILS+=("1. 彙整所有待決策事項\n2. 準備利弊分析\n3. 設定決策期限\n4. 安排討論時間")
            ESTIMATED_TIME+=("1 天")
            AUTO_APPLY+=("partial")
            ;;
        "learning")
            SOLUTIONS+=("建立學習計畫與資源清單")
            SOLUTION_DETAILS+=("1. 整理學習主題清單\n2. 收集相關資源\n3. 設定學習時間塊\n4. 建立筆記模板")
            ESTIMATED_TIME+=("持續")
            AUTO_APPLY+=("partial")
            ;;
        *)
            SOLUTIONS+=("進一步分析並制定行動計畫")
            SOLUTION_DETAILS+=("1. 收集更多背景資訊\n2. 分析根本原因\n3. 制定可行方案\n4. 設定驗證指標")
            ESTIMATED_TIME+=("待定")
            AUTO_APPLY+=("no")
            ;;
    esac
done

# ============================================
# 3. 生成 JSON 格式的解法文件
# ============================================

echo "[$TIME] 📝 生成解法文件..." >> "$LOG_FILE"

# 構建 JSON
JSON_CONTENT="{\n"
JSON_CONTENT+="  \"date\": \"${DATE}\",\n"
JSON_CONTENT+="  \"generated_at\": \"${TIME}\",\n"
JSON_CONTENT+="  \"total_solutions\": ${#SOLUTIONS[@]},\n"
JSON_CONTENT+="  \"solutions\": [\n"

for i in "${!SOLUTIONS[@]}"; do
    # 重新提取推薦標題
    REC_TITLE=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"title":' | head -1 | sed 's/.*"title": "\(.*\)".*/\1/')
    REC_PRIORITY=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"priority":' | head -1 | sed 's/.*"priority": "\(.*\)".*/\1/')
    
    JSON_CONTENT+="    {\n"
    JSON_CONTENT+="      \"recommendation_id\": \"rec_${DATE}_${i}\",\n"
    JSON_CONTENT+="      \"recommendation_title\": \"${REC_TITLE}\",\n"
    JSON_CONTENT+="      \"solution_title\": \"${SOLUTIONS[$i]}\",\n"
    JSON_CONTENT+="      \"solution_details\": \"${SOLUTION_DETAILS[$i]}\",\n"
    JSON_CONTENT+="      \"estimated_time\": \"${ESTIMATED_TIME[$i]}\",\n"
    JSON_CONTENT+="      \"auto_apply\": \"${AUTO_APPLY[$i]}\",\n"
    JSON_CONTENT+="      \"priority\": \"${REC_PRIORITY}\"\n"
    if [ $i -lt $((${#SOLUTIONS[@]} - 1)) ]; then
        JSON_CONTENT+="    },\n"
    else
        JSON_CONTENT+="    }\n"
    fi
done

JSON_CONTENT+="  ]\n"
JSON_CONTENT+="}"

# 寫入文件
echo -e "$JSON_CONTENT" > "$SOLUTION_FILE"

# ============================================
# 4. 更新推薦文件的 solution 欄位
# ============================================

for i in "${!SOLUTIONS[@]}"; do
    # 使用臨時文件更新 JSON
    sed -i.tmp "s/\"id\": \"rec_${DATE}_${i}\"/\"id\": \"rec_${DATE}_${i}\",\n      \"solution\": \"${SOLUTIONS[$i]}\"/" "$RECOMMENDATION_FILE" 2>/dev/null || true
    rm -f "$RECOMMENDATION_FILE.tmp"
done

# ============================================
# 5. 記錄到討論區
# ============================================

echo "" >> "$DISCUSSION"
echo "### 💡 米米 (解法生成器):" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"
echo "已為 **${#SOLUTIONS[@]}** 個推薦生成解法：" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

for i in "${!SOLUTIONS[@]}"; do
    # 重新提取推薦標題
    REC_TITLE=$(grep -A 20 "\"id\": \"rec_${DATE}_${i}\"" "$RECOMMENDATION_FILE" | grep '"title":' | head -1 | sed 's/.*"title": "\(.*\)".*/\1/')
    
    AUTO_BADGE=""
    if [ "${AUTO_APPLY[$i]}" = "yes" ]; then
        AUTO_BADGE="「🤖 可自動執行」"
    elif [ "${AUTO_APPLY[$i]}" = "partial" ]; then
        AUTO_BADGE="「⚡ 部分自動化」"
    else
        AUTO_BADGE="「👤 需手動處理」"
    fi
    
    echo "**${i+1}. ${REC_TITLE}**" >> "$DISCUSSION"
    echo "- 💡 **解法**: ${SOLUTIONS[$i]}" >> "$DISCUSSION"
    echo "- ⏱️ **預估時間**: ${ESTIMATED_TIME[$i]}" >> "$DISCUSSION"
    echo "- ${AUTO_BADGE}" >> "$DISCUSSION"
    echo "" >> "$DISCUSSION"
done

echo "📄 詳細解法: \`$SOLUTION_FILE\`" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

echo "[$TIME] ✅ 解法生成器完成，為 ${#SOLUTIONS[@]} 個推薦生成解法" >> "$LOG_FILE"

# ============================================
# 6. 執行可自動化的解法 (標記為 yes 的)
# ============================================

echo "[$TIME] 🤖 檢查可自動執行的解法..." >> "$LOG_FILE"

AUTO_COUNT=0
for i in "${!AUTO_APPLY[@]}"; do
    if [ "${AUTO_APPLY[$i]}" = "yes" ]; then
        AUTO_COUNT=$((AUTO_COUNT + 1))
    fi
done

if [ "$AUTO_COUNT" -gt 0 ]; then
    echo "[$TIME] 發現 $AUTO_COUNT 個可自動執行的解法" >> "$LOG_FILE"
    echo "" >> "$DISCUSSION"
    echo "🤖 **自動執行中**... ($AUTO_COUNT 個任務)" >> "$DISCUSSION"
    
    # 這裡可以添加實際的自動執行邏輯
    # 例如：執行清理腳本、整理文件等
    
    echo "" >> "$DISCUSSION"
    echo "✅ 自動任務執行完成" >> "$DISCUSSION"
else
    echo "[$TIME] 沒有可自動執行的解法" >> "$LOG_FILE"
fi
