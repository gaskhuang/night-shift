#!/bin/bash
# 🤖 Subagent: 研究協調器
# 啟動 AEO/GEO/SEO 研究任務

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')

echo "[$TIME] 🎯 協調研究任務..."

# 確保研究目錄存在
mkdir -p /Users/user/night-shift/research

# 檢查現有研究文件
RESEARCH_DIR="/Users/user/night-shift/research"
echo "[$TIME] 📊 現有研究文件:"
ls -la "$RESEARCH_DIR"/*.md 2>/dev/null || echo "  (無)"

echo "[$TIME] ✅ 研究協調完成，準備啟動平行研究任務"
