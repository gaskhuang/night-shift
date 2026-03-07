#!/bin/bash
# 🤖 Subagent: 知識庫同步
# 同步 second_brain.md 等知識庫文件

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 📚 知識庫同步任務..."

# 檢查知識庫文件
BRAIN_FILES=(
    "/Users/user/second_brain.md"
    "/Users/user/lobster_second_brain.md"
)

for file in "${BRAIN_FILES[@]}"; do
    if [ -f "$file" ]; then
        LINES=$(wc -l < "$file" 2>/dev/null || echo 0)
        MODIFIED=$(stat -f "%Sm" -t "%Y-%m-%d" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1)
        echo "[$TIME] ✅ $(basename "$file"): $LINES 行 (修改: $MODIFIED)"
    else
        echo "[$TIME] ⚠️ $(basename "$file") 不存在"
    fi
done

echo "[$TIME] ✅ 知識庫同步完成"
