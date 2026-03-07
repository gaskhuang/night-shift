#!/bin/bash
# 🤖 Subagent: 研究結果整合
# 整合 AEO/GEO 研究結果，生成摘要

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
RESEARCH_DIR="/Users/user/night-shift/research"

echo "[$TIME] 🔍 整合研究結果..."

# 檢查研究文件
for file in aeo_insights.md geo_insights.md; do
    if [ -f "$RESEARCH_DIR/$file" ]; then
        LINES=$(wc -l < "$RESEARCH_DIR/$file")
        echo "[$TIME] ✅ $file: $LINES 行"
    else
        echo "[$TIME] ⚠️ $file: 尚未生成"
    fi
done

# 生成當日研究摘要
SUMMARY_FILE="$RESEARCH_DIR/summary_${DATE}.md"
cat > "$SUMMARY_FILE" << EOF
# 📊 研究摘要 - ${DATE}

生成時間: ${TIME}

## AEO/GEO 趨勢

待補充具體發現...

## 建議行動

1. 檢視完整研究文件
2. 決定是否整合到知識庫

---
*自動生成*
EOF

echo "[$TIME] ✅ 研究摘要已生成: $SUMMARY_FILE"
