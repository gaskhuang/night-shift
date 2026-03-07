#!/bin/bash
# 🔍 GEO (Generative Engine Optimization) 研究員 Subagent
# 每晚自動搜尋 GEO 最新趨勢並更新研究文件

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
RESEARCH_DIR="/Users/user/night-shift/research"
OUTPUT_FILE="$RESEARCH_DIR/geo_insights.md"

mkdir -p "$RESEARCH_DIR"

# 檢查 tavily skill 是否可用
TAVILY_CMD="/Users/user/skills/tavily-search/scripts/search.mjs"

if [ ! -f "$TAVILY_CMD" ]; then
    echo "[$TIME] ⚠️ Tavily search 不可用，跳過 GEO 研究"
    exit 0
fi

echo "[$TIME] 🔍 開始 GEO 研究..."

# 搜尋 GEO 相關最新資訊
echo "[$TIME]   - 搜尋: GEO trends 2026..."
node "$TAVILY_CMD" "GEO Generative Engine Optimization AI search 2026" -n 5 > "/tmp/geo_trends_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: LLM optimization..."
node "$TAVILY_CMD" "LLM optimization ChatGPT Claude Gemini visibility" -n 5 > "/tmp/llm_opt_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: AI citation strategies..."
node "$TAVILY_CMD" "AI search citations brand mentions visibility" -n 5 > "/tmp/ai_citations_${DATE}.md" 2>/dev/null || true

# 更新研究文件（追加模式）
cat >> "$OUTPUT_FILE" << EOF

---

## 📅 ${DATE} 更新

### 🔥 GEO 最新趨勢

$(cat "/tmp/geo_trends_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 🧠 LLM 優化策略

$(cat "/tmp/llm_opt_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 📎 AI 引用策略

$(cat "/tmp/ai_citations_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 💡 行動建議

- [ ] 檢查品牌在 ChatGPT/Claude 中的可見度
- [ ] 建立品牌知識圖譜內容
- [ ] 優化權威性內容以獲得 AI 引用

*研究時間: ${TIME}*

EOF

# 清理暫存檔
rm -f "/tmp/geo_trends_${DATE}.md" "/tmp/llm_opt_${DATE}.md" "/tmp/ai_citations_${DATE}.md"

echo "[$TIME] ✅ GEO 研究完成，已更新 $OUTPUT_FILE"
