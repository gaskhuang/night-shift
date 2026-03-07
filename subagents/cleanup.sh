#!/bin/bash
# 🤖 Subagent: 清理任務
# 清理臨時檔案，準備下次夜班

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 🧹 開始清理..."

# 清理隊列目錄（保留最後3天）
QUEUE_DIR="/tmp/night-shift-queue"
if [ -d "$QUEUE_DIR" ]; then
    find "$QUEUE_DIR" -name "*.txt" -mtime +3 -delete 2>/dev/null || true
    echo "[$TIME] ✅ 清理舊任務檔案"
fi

# 清理 PID file
rm -f /tmp/night-shift-v2.pid
rm -f /tmp/night-shift.pid
rm -f /tmp/night-shift-safety-lock

echo "[$TIME] ✅ 清理完成，夜班正式結束"
