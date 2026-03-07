#!/bin/bash
# 🌙 AI 夜班系統 v2.0 - 優化排程器
# 每20分鐘一個任務，平行處理，智能調度

set -e

export PATH="/usr/local/bin:/opt/homebrew/bin:/Users/user/.nvm/versions/node/v24.14.0/bin:/usr/bin:/bin"
export HOME="/Users/user"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_DIR="/Users/user/night-shift/logs"
LOG_FILE="$LOG_DIR/night-shift-${DATE}.log"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${DATE}.md"
PID_FILE="/tmp/night-shift-v2.pid"
QUEUE_DIR="/tmp/night-shift-queue"

# 確保目錄存在
mkdir -p "$LOG_DIR" "$QUEUE_DIR"

# 檢查是否已在執行
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if ps -p "$OLD_PID" > /dev/null 2>&1; then
        echo "[$TIME] ⚠️ 夜班已在執行中 (PID: $OLD_PID)，跳過" >> "$LOG_FILE"
        exit 0
    fi
fi

echo $$ > "$PID_FILE"

# ============================================
# 📝 日誌函數
# ============================================
log() {
    echo "[$(date '+%H:%M')] $1" | tee -a "$LOG_FILE"
}

# ============================================
# 🤖 Subagent 任務執行器（背景執行）
# ============================================
run_subagent() {
    local task_name="$1"
    local task_script="$2"
    local task_id="${DATE}_${task_name}_$(date +%s)"
    local output_file="$QUEUE_DIR/${task_id}.txt"
    
    log "🤖 啟動 Subagent: $task_name"
    
    # 背景執行任務
    (
        echo "=== Task: $task_name | Started: $(date) ===" > "$output_file"
        if bash "$task_script" >> "$output_file" 2>&1; then
            echo "=== Completed: $(date) | Status: SUCCESS ===" >> "$output_file"
            log "✅ Subagent $task_name 完成"
        else
            echo "=== Completed: $(date) | Status: FAILED ===" >> "$output_file"
            log "❌ Subagent $task_name 失敗"
        fi
        
        # 通知討論區
        echo "" >> "$DISCUSSION"
        echo "### 🤖 $task_name - $(date '+%H:%M')" >> "$DISCUSSION"
        head -20 "$output_file" >> "$DISCUSSION"
        echo "" >> "$DISCUSSION"
    ) &
    
    # 返回進程ID
    echo $!
}

# ============================================
# ⏰ 任務定義（20分鐘間隔）
# ============================================
# 23:00 開始，每20分鐘一個任務，共24個任務到06:00
# 部分任務可以平行執行

declare -A TASKS
declare -A TASK_SCRIPTS
declare -A TASK_CAN_PARALLEL

# Round 1: 23:00 - 23:40 (系統檢查 + 待辦抓取)
TASKS["2300"]="system_check"
TASK_SCRIPTS["2300"]="/Users/user/night-shift/tech-lead/system_check.sh"
TASK_CAN_PARALLEL["2300"]="false"

TASKS["2320"]="todo_sync"
TASK_SCRIPTS["2320"]="/Users/user/night-shift/subagents/todo_sync.sh"
TASK_CAN_PARALLEL["2320"]="true"

# Round 2: 00:00 - 00:40 (巡邏 & 修復)
TASKS["0000"]="log_patrol"
TASK_SCRIPTS["0000"]="/Users/user/night-shift/tech-lead/log_patrol.sh"
TASK_CAN_PARALLEL["0000"]="false"

TASKS["0020"]="bug_fix"
TASK_SCRIPTS["0020"]="/Users/user/night-shift/subagents/bug_fixer.sh"
TASK_CAN_PARALLEL["0020"]="true"

# Round 3: 01:00 - 01:40 (知識庫整理)
TASKS["0100"]="memory_organize"
TASK_SCRIPTS["0100"]="/Users/user/night-shift/subagents/memory_organizer.sh"
TASK_CAN_PARALLEL["0100"]="true"

TASKS["0120"]="knowledge_sync"
TASK_SCRIPTS["0120"]="/Users/user/night-shift/subagents/knowledge_sync.sh"
TASK_CAN_PARALLEL["0120"]="true"

# Round 4: 02:00 - 02:40 (研究任務 - AEO/GEO/SEO 平行執行)
TASKS["0200"]="research_start"
TASK_SCRIPTS["0200"]="/Users/user/night-shift/subagents/research_coordinator.sh"
TASK_CAN_PARALLEL["0200"]="false"

TASKS["0220"]="aeo_research"
TASK_SCRIPTS["0220"]="/Users/user/night-shift/subagents/aeo_researcher.sh"
TASK_CAN_PARALLEL["0220"]="true"

# Round 5: 03:00 - 03:40 (研究結果整合 + 內容生成)
TASKS["0300"]="geo_research"
TASK_SCRIPTS["0300"]="/Users/user/night-shift/subagents/geo_researcher.sh"
TASK_CAN_PARALLEL["0300"]="true"

TASKS["0320"]="research_summary"
TASK_SCRIPTS["0320"]="/Users/user/night-shift/subagents/research_summary.sh"
TASK_CAN_PARALLEL["0320"]="true"

# Round 6: 04:00 - 04:40 (內容生成 + 文件整理)
TASKS["0400"]="content_generate"
TASK_SCRIPTS["0400"]="/Users/user/night-shift/subagents/content_generator.sh"
TASK_CAN_PARALLEL["0400"]="true"

TASKS["0420"]="doc_organize"
TASK_SCRIPTS["0420"]="/Users/user/night-shift/subagents/doc_organizer.sh"
TASK_CAN_PARALLEL["0420"]="true"

# Round 7: 05:00 - 05:40 (提案準備)
TASKS["0500"]="proposal_prep"
TASK_SCRIPTS["0500"]="/Users/user/night-shift/subagents/proposal_prep.sh"
TASK_CAN_PARALLEL["0500"]="true"

TASKS["0520"]="draft_report"
TASK_SCRIPTS["0520"]="/Users/user/night-shift/subagents/draft_report.sh"
TASK_CAN_PARALLEL["0520"]="true"

# Round 8: 06:00 (最終檢查 & 晨報生成)
TASKS["0600"]="final_check"
TASK_SCRIPTS["0600"]="/Users/user/night-shift/subagents/final_check.sh"
TASK_CAN_PARALLEL["0600"]="false"

# 額外任務：06:20 清理
TASKS["0620"]="cleanup"
TASK_SCRIPTS["0620"]="/Users/user/night-shift/subagents/cleanup.sh"
TASK_CAN_PARALLEL["0620"]="true"

# ============================================
# 🎯 主執行邏輯
# ============================================

CURRENT_TIME=$(date '+%H%M')
CURRENT_HOUR=$(date '+%H')

log "========================================"
log "🌙 夜班系統 v2.0 - $DATE $TIME"
log "========================================"

# 夜班時間檢查 (23:00 - 06:30)
if [ "$CURRENT_HOUR" -ge 7 ] && [ "$CURRENT_HOUR" -lt 23 ]; then
    log "⏰ 非夜班時間，跳過執行"
    rm -f "$PID_FILE"
    exit 0
fi

# 初始化討論區（只有23:00第一次執行時）
if [ "$CURRENT_TIME" = "2300" ] || [ ! -f "$DISCUSSION" ]; then
    cat > "$DISCUSSION" << EOF
# 🌙 夜班討論區 - ${DATE}

> Tech Lead (J) + PM (米米) 協作空間
> 執行模式: 每20分鐘一個任務 + Subagent平行處理

## 🚀 夜班啟動 - ${TIME}

### J:
夜班開始！系統準備就緒。
開始執行第一輪任務...

---

EOF
    log "✅ 討論區已建立"
    touch "/tmp/night-shift-safety-lock"
    log "🛡️ 安全護欄已啟動"
fi

# 執行當前任務
if [ -n "${TASKS[$CURRENT_TIME]}" ]; then
    TASK_NAME="${TASKS[$CURRENT_TIME]}"
    TASK_SCRIPT="${TASK_SCRIPTS[$CURRENT_TIME]}"
    CAN_PARALLEL="${TASK_CAN_PARALLEL[$CURRENT_TIME]}"
    
    log "========================================"
    log "🎯 執行任務: $TASK_NAME ($CURRENT_TIME)"
    log "========================================"
    
    # 記錄到討論區
    echo "" >> "$DISCUSSION"
    echo "## $TIME - $TASK_NAME 開始" >> "$DISCUSSION"
    echo "" >> "$DISCUSSION"
    
    # 檢查腳本是否存在
    if [ -f "$TASK_SCRIPT" ]; then
        if [ "$CAN_PARALLEL" = "true" ]; then
            # 平行執行
            PID=$(run_subagent "$TASK_NAME" "$TASK_SCRIPT")
            log "🔄 Subagent PID: $PID (背景執行中)"
            echo "🤖 已啟動 Subagent 背景處理 (PID: $PID)" >> "$DISCUSSION"
        else
            # 同步執行（需要等待結果的任務）
            log "⏳ 同步執行任務..."
            if bash "$TASK_SCRIPT" >> "$LOG_FILE" 2>&1; then
                log "✅ 任務完成: $TASK_NAME"
                echo "✅ 任務完成" >> "$DISCUSSION"
            else
                log "❌ 任務失敗: $TASK_NAME"
                echo "❌ 任務執行失敗，已記錄到日誌" >> "$DISCUSSION"
            fi
        fi
    else
        log "⚠️ 腳本不存在: $TASK_SCRIPT"
        echo "⚠️ 腳本待實現: $TASK_NAME" >> "$DISCUSSION"
    fi
    
    # 如果是 Round 8 最終任務，生成晨報
    if [ "$CURRENT_TIME" = "0600" ]; then
        log "🌅 生成晨報..."
        /Users/user/night-shift/generate_morning_report.sh >> "$LOG_FILE" 2>&1 || true
        
        echo "" >> "$DISCUSSION"
        echo "---" >> "$DISCUSSION"
        echo "## 🌅 夜班結束 - $TIME" >> "$DISCUSSION"
        echo "晨報已生成！期待 G大 的 feedback~" >> "$DISCUSSION"
        
        # 清理
        rm -f "$PID_FILE"
        rm -f "/tmp/night-shift-safety-lock"
    fi
else
    log "ℹ️ 當前時間無任務 ($CURRENT_TIME)"
fi

# 檢查等待中的 Subagent 任務
if ls "$QUEUE_DIR"/*.txt 1> /dev/null 2>&1; then
    PENDING_COUNT=$(ls "$QUEUE_DIR"/*.txt 2>/dev/null | wc -l)
    if [ "$PENDING_COUNT" -gt 0 ]; then
        log "📋 有 $PENDING_COUNT 個 Subagent 任務在執行或已完成"
    fi
fi

log "✅ 本輪排程完成"

# 清理 PID file（除非是06:00最後一輪）
if [ "$CURRENT_TIME" != "0600" ]; then
    rm -f "$PID_FILE"
fi
