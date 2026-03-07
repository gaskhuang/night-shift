#!/bin/bash
# 🔄 從原始 night-shift 目錄同步並推送
# 這個腳本會先複製最新內容，然後推送到 GitHub

SOURCE_DIR="/Users/user/night-shift"
REPO_DIR="/Users/user/night-shift-repo"
COMMIT_MSG="${1:-"Update: $(date '+%Y-%m-%d %H:%M')"}"

# 顏色
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔄 Night Shift 同步推送工具${NC}"
echo "=========================================="

# 同步檔案
echo -e "${YELLOW}📂 從 $SOURCE_DIR 同步到 $REPO_DIR${NC}"

# 使用 rsync 同步，排除 .git 和腳本本身
rsync -av "$SOURCE_DIR/" "$REPO_DIR/" \
    --exclude='.git' \
    --exclude='auto_push.sh' \
    --exclude='sync_and_push.sh' \
    --delete

cd "$REPO_DIR"

# 檢查是否有變更
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${YELLOW}ℹ️ 沒有新的變更需要推送${NC}"
    exit 0
fi

# Git 操作
echo -e "${YELLOW}📦 Git 提交中...${NC}"
git add .
git commit -m "$COMMIT_MSG"
git push origin main

echo -e "${GREEN}✅ 推送成功！${NC}"
echo -e "${GREEN}🔗 https://github.com/gaskhuang/night-shift${NC}"
