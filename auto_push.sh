#!/bin/bash
# 🌙 夜班系統自動上傳腳本
# 自動將產出的 md, log, report 推送到 GitHub
# 使用方法: ./auto_push.sh ["commit message"]

set -e

REPO_DIR="/Users/user/night-shift-repo"
COMMIT_MSG="${1:-"Night Shift update: $(date '+%Y-%m-%d %H:%M')"}"

# 顏色定義
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}🌙 Night Shift Auto-Push 啟動...${NC}"
echo "=========================================="

cd "$REPO_DIR"

# 檢查是否有變更
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${YELLOW}ℹ️ 沒有新的變更需要推送${NC}"
    exit 0
fi

# 同步最新的 night-shift 內容
echo -e "${YELLOW}📥 同步最新內容...${NC}"
rsync -av --delete /Users/user/night-shift/ "$REPO_DIR/" --exclude='.git' --exclude='auto_push.sh'

# 添加所有變更
echo -e "${YELLOW}📦 添加檔案...${NC}"
git add .

# 顯示將要提交的檔案
echo -e "${GREEN}📋 將要提交的檔案:${NC}"
git status --short

# 提交
echo -e "${YELLOW}💾 提交變更: $COMMIT_MSG${NC}"
git commit -m "$COMMIT_MSG"

# 推送到 GitHub
echo -e "${YELLOW}🚀 推送到 GitHub...${NC}"
git push origin main

echo -e "${GREEN}✅ 上傳完成！${NC}"
echo "=========================================="
echo -e "${GREEN}🌙 Night Shift 已同步到:${NC}"
echo -e "${GREEN}   https://github.com/gaskhuang/night-shift${NC}"
