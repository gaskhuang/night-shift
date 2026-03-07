#!/bin/bash
# 🤖 Subagent: 記憶庫整理
# 整理 memory/ 目錄，統計檔案，檢查需要歸檔的內容

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
MEMORY_DIR="/Users/user/memory"

echo "[$TIME] 📚 開始整理記憶庫..."

if [ -d "$MEMORY_DIR" ]; then
    # 統計檔案數
    TOTAL_FILES=$(find "$MEMORY_DIR" -name "*.md" | wc -l)
    TODAY_FILES=$(find "$MEMORY_DIR" -name "${DATE}*.md" | wc -l)
    
    echo "[$TIME] 📊 記憶庫統計:"
    echo "  - 總檔案數: $TOTAL_FILES"
    echo "  - 今日新增: $TODAY_FILES"
    
    # 檢查大檔案（可能需要歸檔）
    LARGE_FILES=$(find "$MEMORY_DIR" -name "*.md" -size +100k 2>/dev/null | wc -l)
    if [ "$LARGE_FILES" -gt 0 ]; then
        echo "  - 大檔案(>100KB): $LARGE_FILES 個（建議整理）"
    fi
else
    echo "[$TIME] ⚠️ memory/ 目錄不存在"
fi

echo "[$TIME] ✅ 記憶庫整理完成"
