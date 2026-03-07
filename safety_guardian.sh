#!/bin/bash
# 🛡️ 夜班安全守護腳本
# 監控夜班系統執行，確保不執行危險操作

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
LOG_FILE="/Users/user/night-shift/logs/safety-${DATE}.log"
SAFETY_LOCK="/tmp/night-shift-safety-lock"

mkdir -p "$(dirname "$LOG_FILE")"

# 危險指令關鍵詞（如果夜班腳本嘗試執行這些，會被攔截）
DANGEROUS_PATTERNS=(
    "rm -rf /"
    "rm -rf ~"
    "rm -rf /Users"
    "rm -rf /System"
    "apikey"
    "api_key"
    "send_message"
    "deploy.*production"
    "git push.*--force"
    "> /dev/null"
    "curl.*http"
    "wget.*http"
)

log_safety() {
    echo "[$TIME] $1" >> "$LOG_FILE"
}

# 初始化安全日誌
log_safety "🛡️ 安全守護啟動"

# 檢查安全鎖
if [ ! -f "$SAFETY_LOCK" ]; then
    log_safety "⚠️ 警告: 安全鎖未找到，正在創建..."
    touch "$SAFETY_LOCK"
fi

# 檢查夜班日誌中是否有危險操作跡象
check_dangerous_operations() {
    night_log="/Users/user/night-shift/logs/night-shift-${DATE}.log"
    
    if [ ! -f "$night_log" ]; then
        return
    fi
    
    for pattern in "${DANGEROUS_PATTERNS[@]}"; do
        if grep -i "$pattern" "$night_log" > /dev/null 2>&1; then
            log_safety "🚨 檢測到潛在危險操作模式: $pattern"
            log_safety "   位置: $night_log"
            
            # 發送警報（這裡只是記錄，不實際發送訊息）
            echo "ALERT: Dangerous pattern detected in night shift: $pattern" >> "$LOG_FILE"
        fi
    done
}

# 檢查磁碟空間（防止寫爆）
check_disk_space() {
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -gt 90 ]; then
        log_safety "🚨 警告: 磁碟使用率高達 ${DISK_USAGE}%"
    elif [ "$DISK_USAGE" -gt 80 ]; then
        log_safety "⚠️ 提醒: 磁碟使用率 ${DISK_USAGE}%"
    fi
}

# 檢查記憶體使用
check_memory() {
    MEMORY_PRESSURE=$(memory_pressure 2>/dev/null | grep "System-wide memory free percentage" | awk '{print $5}' | sed 's/%//' || echo "50")
    
    if [ "$MEMORY_PRESSURE" -lt 10 ]; then
        log_safety "🚨 警告: 記憶體壓力過高"
    fi
}

# 執行檢查
check_dangerous_operations
check_disk_space
check_memory

log_safety "✅ 安全檢查完成"
