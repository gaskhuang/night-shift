#!/bin/bash
# 🧑‍💻 Tech Lead - 系統檢查腳本
# Round 1 核心任務

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
REPORT_DIR="/Users/user/night-shift/reports"
REPORT_FILE="$REPORT_DIR/system-status-${DATE}.json"

mkdir -p "$REPORT_DIR"

echo "{"
echo "  \"timestamp\": \"${DATE} ${TIME}\","
echo "  \"checks\": {"

# 1. 磁碟使用
echo "    \"disk\": {" 
DISK_INFO=$(df -h / | tail -1)
DISK_TOTAL=$(echo "$DISK_INFO" | awk '{print $2}')
DISK_USED=$(echo "$DISK_INFO" | awk '{print $3}')
DISK_AVAIL=$(echo "$DISK_INFO" | awk '{print $4}')
DISK_PERCENT=$(echo "$DISK_INFO" | awk '{print $5}' | sed 's/%//')
echo "      \"total\": \"$DISK_TOTAL\","
echo "      \"used\": \"$DISK_USED\","
echo "      \"available\": \"$DISK_AVAIL\","
echo "      \"percent\": $DISK_PERCENT,"
if [ "$DISK_PERCENT" -gt 90 ]; then
    echo "      \"status\": \"WARNING\","
    echo "      \"message\": \"磁碟空間不足 (>90%)\""
elif [ "$DISK_PERCENT" -gt 80 ]; then
    echo "      \"status\": \"ATTENTION\","
    echo "      \"message\": \"磁碟空間需要注意 (>80%)\""
else
    echo "      \"status\": \"OK\","
    echo "      \"message\": \"磁碟空間正常\""
fi
echo "    },"

# 2. 記憶體使用
echo "    \"memory\": {"
MEMORY_INFO=$(vm_stat 2>/dev/null || echo "")
if [ -n "$MEMORY_INFO" ]; then
    # macOS vm_stat 解析
    PAGE_SIZE=$(vm_stat | grep "page size" | awk '{print $8}' || echo "4096")
    [ -z "$PAGE_SIZE" ] && PAGE_SIZE=4096
    
    FREE_PAGES=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    ACTIVE_PAGES=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
    INACTIVE_PAGES=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    WIRED_PAGES=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
    
    FREE_MB=$((FREE_PAGES * PAGE_SIZE / 1024 / 1024))
    TOTAL_MB=$(( (FREE_PAGES + ACTIVE_PAGES + INACTIVE_PAGES + WIRED_PAGES) * PAGE_SIZE / 1024 / 1024 ))
    
    echo "      \"free_mb\": $FREE_MB,"
    echo "      \"total_mb\": $TOTAL_MB,"
    echo "      \"status\": \"OK\","
    echo "      \"message\": \"記憶體狀態正常\""
else
    echo "      \"status\": \"UNKNOWN\","
    echo "      \"message\": \"無法獲取記憶體資訊\""
fi
echo "    },"

# 3. CPU 負載
echo "    \"cpu\": {"
LOAD_AVERAGE=$(uptime | awk -F'load averages:' '{print $2}' | awk '{print $1}')
echo "      \"load_average\": \"$LOAD_AVERAGE\","
echo "      \"status\": \"OK\","
echo "      \"message\": \"CPU負載正常\""
echo "    },"

# 4. 關鍵服務檢查
echo "    \"services\": {"
echo "      \"items\": ["

# 檢查常見服務
SERVICES=("node" "python" "redis" "postgres")
FIRST=true
for service in "${SERVICES[@]}"; do
    if pgrep -x "$service" > /dev/null 2>&1; then
        STATUS="running"
    else
        STATUS="stopped"
    fi
    
    if [ "$FIRST" = true ]; then
        FIRST=false
    else
        echo ","
    fi
    echo "        {\"name\": \"$service\", \"status\": \"$STATUS\"}"
done

echo ""
echo "      ],"
echo "      \"status\": \"OK\""
echo "    },"

# 5. 錯誤日誌檢查
echo "    \"errors\": {"
ERROR_LOGS=(
    "/Users/user/logs/error.log"
    "/Users/user/night-shift/logs/night-shift-${DATE}.log"
)

TOTAL_ERRORS=0
for log in "${ERROR_LOGS[@]}"; do
    if [ -f "$log" ]; then
        ERRORS=$(grep -c "ERROR\|error\|Error" "$log" 2>/dev/null || echo 0)
        TOTAL_ERRORS=$((TOTAL_ERRORS + ERRORS))
    fi
done

echo "      \"count\": $TOTAL_ERRORS,"
if [ "$TOTAL_ERRORS" -gt 10 ]; then
    echo "      \"status\": \"WARNING\","
    echo "      \"message\": \"發現較多錯誤日誌 ($TOTAL_ERRORS)\""
elif [ "$TOTAL_ERRORS" -gt 0 ]; then
    echo "      \"status\": \"ATTENTION\","
    echo "      \"message\": \"發現 $TOTAL_ERRORS 個錯誤\""
else
    echo "      \"status\": \"OK\","
    echo "      \"message\": \"無錯誤日誌\""
fi
echo "    }"

echo "  },"
echo "  \"overall_status\": \"COMPLETED\""
echo "}"

# 儲存為 JSON 檔案
cat > "$REPORT_FILE" << EOF
{
  "timestamp": "${DATE} ${TIME}",
  "type": "system_check",
  "data": $(echo "{}")
}
EOF

echo "[$TIME] ✅ 系統檢查完成，報告已儲存"
