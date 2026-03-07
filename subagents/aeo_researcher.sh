#!/bin/bash
# 🔍 AEO (Answer Engine Optimization) 研究員 Subagent
# 每晚自動搜尋 AEO 最新趨勢並更新研究文件

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
RESEARCH_DIR="/Users/user/night-shift/research"
OUTPUT_FILE="$RESEARCH_DIR/aeo_insights.md"

mkdir -p "$RESEARCH_DIR"

# 檢查 tavily skill 是否可用
TAVILY_CMD="/Users/user/skills/tavily-search/scripts/search.mjs"

if [ ! -f "$TAVILY_CMD" ]; then
    echo "[$TIME] ⚠️ Tavily search 不可用，跳過 AEO 研究"
    exit 0
fi

echo "[$TIME] 🔍 開始 AEO 研究..."

# 搜尋 AEO 相關最新資訊
echo "[$TIME]   - 搜尋: AEO trends 2026..."
node "$TAVILY_CMD" "AEO Answer Engine Optimization trends 2026" -n 5 > "/tmp/aeo_trends_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: AI search optimization..."
node "$TAVILY_CMD" "AI search optimization ChatGPT Perplexity" -n 5 > "/tmp/ai_search_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: structured data SEO..."
node "$TAVILY_CMD" "structured data schema markup SEO 2026" -n 5 > "/tmp/structured_data_${DATE}.md" 2>/dev/null || true

# 更新研究文件（追加模式）
cat >> "$OUTPUT_FILE" << EOF

---

## 📅 ${DATE} 更新

### 🔥 AEO 最新趨勢

$(cat "/tmp/aeo_trends_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 🤖 AI 搜尋優化

$(cat "/tmp/ai_search_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 📊 結構化數據

$(cat "/tmp/structured_data_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 💡 行動建議

- [ ] 檢視網站 FAQ Schema 標記
- [ ] 優化 Featured Snippet 內容
- [ ] 測試 AI 搜尋引擎抓取結果

*研究時間: ${TIME}*

EOF

# 清理暫存檔
rm -f "/tmp/aeo_trends_${DATE}.md" "/tmp/ai_search_${DATE}.md" "/tmp/structured_data_${DATE}.md"

echo "[$TIME] ✅ AEO 研究完成，已更新 $OUTPUT_FILE"
