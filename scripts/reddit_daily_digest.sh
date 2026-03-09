#!/bin/bash
# Reddit 每日精選排程腳本
# 每天早上 8 點執行

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
SKILL_DIR="/Users/user/.agents/skills/reddit"
OUTPUT_DIR="/Users/user/night-shift/reports"
OUTPUT_FILE="$OUTPUT_DIR/reddit-digest-${DATE}.md"

# 確保輸出目錄存在
mkdir -p "$OUTPUT_DIR"

echo "# 🎯 Reddit 每日精選 - ${DATE}" > "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"
echo "生成時間: ${TIME}" >> "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# 訂閱的 subreddits
SUBREDDITS=("machinelearning" "OpenAI" "technology" "webdev" "programming")

for sub in "${SUBREDDITS[@]}"; do
    echo "## r/${sub}" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
    
    # 取得熱門文章
    python3 "$SKILL_DIR/scripts/get_posts.py" "$sub" --limit 5 >> "$OUTPUT_FILE" 2>&1
    
    echo "" >> "$OUTPUT_FILE"
    echo "---" >> "$OUTPUT_FILE"
    echo "" >> "$OUTPUT_FILE"
done

echo "✅ Reddit digest 已生成: $OUTPUT_FILE"
