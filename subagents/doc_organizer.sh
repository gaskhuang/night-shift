#!/bin/bash
# 🤖 Subagent: 文件整理
# 整理 SOP 和文件

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 📂 文件整理任務..."

# 統計各類文件
echo "[$TIME] 📊 文件統計:"

# AGENTS.md 等系統文件
SYSTEM_DOCS=$(find /Users/user -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
echo "  - 系統文件: $SYSTEM_DOCS 個"

# memory 目錄
if [ -d "/Users/user/memory" ]; then
    MEMORY_COUNT=$(find /Users/user/memory -name "*.md" | wc -l)
    echo "  - 記憶文件: $MEMORY_COUNT 個"
fi

# night-shift 文件
NS_FILES=$(find /Users/user/night-shift -name "*.md" 2>/dev/null | wc -l)
echo "  - 夜班文件: $NS_FILES 個"

echo "[$TIME] ✅ 文件整理完成"
