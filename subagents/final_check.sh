#!/bin/bash
# 🤖 Subagent: 最終檢查
# 夜班最後一輪，檢查所有任務完成狀態

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 🔍 執行最終檢查..."

# 檢查關鍵檔案
FILES_TO_CHECK=(
    "/Users/user/night-shift/logs/night-shift-${DATE}.log"
    "/Users/user/night-shift/discussion/collaboration_${DATE}.md"
    "/Users/user/night-shift/research/aeo_insights.md"
    "/Users/user/night-shift/research/geo_insights.md"
)

echo "[$TIME] 📁 檔案檢查:"
for file in "${FILES_TO_CHECK[@]}"; do
    if [ -f "$file" ]; then
        SIZE=$(stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null || echo "0")
        echo "  ✅ $(basename "$file") (${SIZE} bytes)"
    else
        echo "  ⚠️ $(basename "$file") 不存在"
    fi
done

# 檢查錯誤
LOG_FILE="/Users/user/night-shift/logs/night-shift-${DATE}.log"
if [ -f "$LOG_FILE" ]; then
    ERRORS=$(grep -c "ERROR\|失敗\|❌" "$LOG_FILE" 2>/dev/null || echo 0)
    if [ "$ERRORS" -gt 0 ]; then
        echo "[$TIME] ⚠️ 發現 $ERRORS 個錯誤/失敗"
    else
        echo "[$TIME] ✅ 無錯誤記錄"
    fi
fi

echo "[$TIME] ✅ 最終檢查完成"
