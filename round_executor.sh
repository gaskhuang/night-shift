#!/bin/bash
# 🌙 AI 夜班系統 - 輪次執行器
# 根據當前時間決定執行哪一輪任務

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
HOUR=$(date '+%H')
LOG_DIR="/Users/user/night-shift/logs"
LOG_FILE="$LOG_DIR/night-shift-${DATE}.log"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${DATE}.md"

# GitHub 同步設定
GITHUB_REPO_DIR="/Users/user/night-shift-repo"
GITHUB_SYNC_ENABLED=true

mkdir -p "$LOG_DIR"

# ============================================
# 🔧 GitHub 自動推送函數
# ============================================
push_to_github() {
    local round_num=$1
    local custom_msg="${2:-"Round $round_num update: $(date '+%Y-%m-%d %H:%M')"}"
    
    if [ "$GITHUB_SYNC_ENABLED" != "true" ]; then
        echo "[$TIME] ℹ️ GitHub 同步已停用" >> "$LOG_FILE"
        return 0
    fi
    
    echo "[$TIME] 🚀 正在同步到 GitHub..." >> "$LOG_FILE"
    
    # 從原始目錄同步最新內容
    if [ -d "$GITHUB_REPO_DIR" ]; then
        rsync -a "/Users/user/night-shift/" "$GITHUB_REPO_DIR/" \
            --exclude='.git' \
            --exclude='auto_push.sh' \
            --exclude='sync_and_push.sh' \
            2>/dev/null || true
        
        cd "$GITHUB_REPO_DIR"
        
        # 檢查是否有變更
        if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null || [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
            git add . > /dev/null 2>&1 || true
            git commit -m "$custom_msg" > /dev/null 2>&1 || true
            git push origin main > /dev/null 2>&1 && \
                echo "[$TIME] ✅ 已推送到 GitHub" >> "$LOG_FILE" || \
                echo "[$TIME] ⚠️ GitHub 推送失敗" >> "$LOG_FILE"
        else
            echo "[$TIME] ℹ️ 沒有新變更需要推送" >> "$LOG_FILE"
        fi
    else
        echo "[$TIME] ⚠️ GitHub 倉庫目錄不存在: $GITHUB_REPO_DIR" >> "$LOG_FILE"
    fi
}

# 決定輪次
if [ "$1" = "auto" ]; then
    case $HOUR in
        23) ROUND=1 ;;
        00) ROUND=2 ;;
        01) ROUND=3 ;;
        02) ROUND=4 ;;
        03) ROUND=5 ;;
        04) ROUND=6 ;;
        05) ROUND=7 ;;
        06) ROUND=8 ;;
        *) 
            echo "[$TIME] ⏰ 非夜班時間 ($HOUR)，跳過執行"
            exit 0
            ;;
    esac
else
    ROUND="$1"
fi

echo "" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"
echo "🌙 Round $ROUND - $TIME" >> "$LOG_FILE"
echo "========================================" >> "$LOG_FILE"

# 記錄到討論區
echo "" >> "$DISCUSSION"
echo "## $TIME - Round $ROUND 開始" >> "$DISCUSSION"
echo "" >> "$DISCUSSION"

# 安全護欄檢查
if [ ! -f "/tmp/night-shift-safety-lock" ]; then
    echo "[$TIME] ⚠️ 安全護欄未啟動，正在初始化..." >> "$LOG_FILE"
    touch "/tmp/night-shift-safety-lock"
fi

# 執行對應輪次任務
case $ROUND in
    1)
        echo "[$TIME] 📝 Round 1: 系統檢查 + 待辦清單抓取" >> "$LOG_FILE"
        /Users/user/night-shift/tech-lead/system_check.sh >> "$LOG_FILE" 2>&1 || true
        echo "### J:" >> "$DISCUSSION"
        echo "✅ 系統檢查完成" >> "$DISCUSSION"
        echo "正在抓取 Google Tasks 待辦清單..." >> "$DISCUSSION"
        ;;
    
    2)
        echo "[$TIME] 🔧 Round 2: Tech Lead - 巡邏 & 修復" >> "$LOG_FILE"
        # 檢查錯誤日誌
        if [ -f "/Users/user/logs/error.log" ]; then
            ERROR_COUNT=$(grep -c "ERROR" /Users/user/logs/error.log 2>/dev/null || echo 0)
            echo "[$TIME] 發現 $ERROR_COUNT 個錯誤" >> "$LOG_FILE"
            echo "### J:" >> "$DISCUSSION"
            echo "發現 $ERROR_COUNT 個錯誤，開始分析..." >> "$DISCUSSION"
        fi
        # 呼叫 subagent 修復小問題
        echo "[$TIME] 🤖 呼叫 Tech Lead Subagent..." >> "$LOG_FILE"
        ;;
    
    3)
        echo "[$TIME] 🔮 Round 3: PM - 智能推薦引擎" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "啟動智能推薦引擎，分析過去3天的數據..." >> "$DISCUSSION"
        # 執行推薦引擎
        /Users/user/night-shift/subagents/recommendation_engine.sh >> "$LOG_FILE" 2>&1 || true
        echo "[$TIME] ✅ 智能推薦完成" >> "$LOG_FILE"
        ;;
    
    4)
        echo "[$TIME] 🔍 Round 4: 研究任務 (AEO/GEO/SEO)" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "開始研究 AEO/GEO 最新趨勢..." >> "$DISCUSSION"
        
        # 執行 AEO 研究
        /Users/user/night-shift/subagents/aeo_researcher.sh >> "$LOG_FILE" 2>&1 || true
        
        # 執行 GEO 研究
        /Users/user/night-shift/subagents/geo_researcher.sh >> "$LOG_FILE" 2>&1 || true
        
        echo "✅ AEO/GEO 研究完成，已更新研究文件" >> "$DISCUSSION"
        ;;
    
    5)
        echo "[$TIME] ✍️ Round 5: 內容生成 (文章/文案)" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "開始撰寫部落格文章..." >> "$DISCUSSION"
        # 呼叫內容生成 subagent
        ;;
    
    6)
        echo "[$TIME] 💡 Round 6: 解法生成器" >> "$LOG_FILE"
        echo "### 米米:" >> "$DISCUSSION"
        echo "為推薦事項生成解法..." >> "$DISCUSSION"
        # 執行解法生成器
        /Users/user/night-shift/subagents/solution_proposer.sh >> "$LOG_FILE" 2>&1 || true
        echo "[$TIME] ✅ 解法生成完成" >> "$LOG_FILE"
        ;;
    
    7)
        echo "[$TIME] 📋 Round 7: 提案準備 & 晨報草稿" >> "$LOG_FILE"
        echo "### J & 米米:" >> "$DISCUSSION"
        echo "整理今晚的工作成果，準備提案..." >> "$DISCUSSION"
        # 生成晨報草稿
        ;;
    
    8)
        echo "[$TIME] 🌅 Round 8: 最終檢查 & 晨報生成" >> "$LOG_FILE"
        echo "### J:" >> "$DISCUSSION"
        echo "夜班即將結束，正在生成最終晨報..." >> "$DISCUSSION"
        
        # 生成最終晨報
        /Users/user/night-shift/generate_morning_report.sh >> "$LOG_FILE" 2>&1 || true
        
        echo "" >> "$DISCUSSION"
        echo "---" >> "$DISCUSSION"
        echo "## 🌅 夜班結束 - $TIME" >> "$DISCUSSION"
        echo "晨報已生成！期待 G大 的feedback~" >> "$DISCUSSION"
        ;;
    
    *)
        echo "[$TIME] ❌ 未知輪次: $ROUND" >> "$LOG_FILE"
        exit 1
        ;;
esac

echo "[$TIME] ✅ Round $ROUND 完成" >> "$LOG_FILE"
echo "" >> "$DISCUSSION"

# ============================================
# 🚀 自動推送到 GitHub
# ============================================
push_to_github "$ROUND" "Night Shift Round $ROUND: $(date '+%Y-%m-%d %H:%M')"
