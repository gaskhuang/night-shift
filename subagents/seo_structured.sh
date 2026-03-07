#!/bin/bash
# 🔍 SEO 結構化數據研究員 Subagent
# 每晚自動搜尋 SEO 結構化數據最新趨勢並更新研究文件

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
RESEARCH_DIR="/Users/user/night-shift/research"
OUTPUT_FILE="$RESEARCH_DIR/seo_structured_data.md"

mkdir -p "$RESEARCH_DIR"

# 檢查 tavily skill 是否可用
TAVILY_CMD="/Users/user/skills/tavily-search/scripts/search.mjs"

if [ ! -f "$TAVILY_CMD" ]; then
    echo "[$TIME] ⚠️ Tavily search 不可用，跳過 SEO 研究"
    exit 0
fi

echo "[$TIME] 🔍 開始 SEO 結構化數據研究..."

# 搜尋 SEO 結構化數據相關最新資訊
echo "[$TIME]   - 搜尋: Schema.org markup 2026..."
node "$TAVILY_CMD" "Schema.org structured data markup SEO 2026" -n 5 > "/tmp/schema_trends_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: JSON-LD best practices..."
node "$TAVILY_CMD" "JSON-LD structured data best practices" -n 5 > "/tmp/jsonld_best_${DATE}.md" 2>/dev/null || true

echo "[$TIME]   - 搜尋: Rich snippets optimization..."
node "$TAVILY_CMD" "rich snippets optimization Google search" -n 5 > "/tmp/rich_snippets_${DATE}.md" 2>/dev/null || true

# 更新研究文件（追加模式）
cat >> "$OUTPUT_FILE" << EOF

---

## 📅 ${DATE} 更新

### 📊 Schema.org 最新趨勢

\$(cat "/tmp/schema_trends_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 💻 JSON-LD 最佳實踐

\$(cat "/tmp/jsonld_best_${DATE}.md" 2>/dev/null || echo "暫無數據")

### ⭐ Rich Snippets 優化

\$(cat "/tmp/rich_snippets_${DATE}.md" 2>/dev/null || echo "暫無數據")

### 💡 行動建議

- [ ] 檢查網站 JSON-LD 標記完整性
- [ ] 確保 Organization Schema 正確
- [ ] 添加 BreadcrumbList 結構化數據
- [ ] 優化 Article/ BlogPosting 標記

*研究時間: ${TIME}*

EOF

# 清理暫存檔
rm -f "/tmp/schema_trends_${DATE}.md" "/tmp/jsonld_best_${DATE}.md" "/tmp/rich_snippets_${DATE}.md"

echo "[$TIME] ✅ SEO 結構化數據研究完成，已更新 $OUTPUT_FILE"
