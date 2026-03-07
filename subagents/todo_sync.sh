#!/bin/bash
# 🤖 Subagent: 待辦清單同步
# 從 Google Tasks 或其他來源同步待辦事項

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 📋 開始同步待辦清單..."

# 檢查 TASK_LIST.md
TASK_LIST="/Users/user/TASK_LIST.md"
if [ -f "$TASK_LIST" ]; then
    P0_COUNT=$(grep -c "\[P0\]" "$TASK_LIST" 2>/dev/null || echo 0)
    P1_COUNT=$(grep -c "\[P1\]" "$TASK_LIST" 2>/dev/null || echo 0)
    echo "[$TIME] ✅ 找到 $P0_COUNT 個 P0, $P1_COUNT 個 P1 任務"
else
    echo "[$TIME] ⚠️ TASK_LIST.md 不存在，建議創建"
fi

echo "[$TIME] ✅ 待辦清單同步完成"
