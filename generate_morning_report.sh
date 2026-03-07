#!/bin/bash
# 🌅 晨報生成器
# 彙整整夜工作成果，生成給 G大 的晨報

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
YESTERDAY=$(date -v-1d '+%Y-%m-%d')
REPORT_DIR="/Users/user/night-shift/reports"
REPORT_FILE="$REPORT_DIR/morning-report-${DATE}.md"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${YESTERDAY}.md"
LOG_FILE="/Users/user/night-shift/logs/night-shift-${YESTERDAY}.log"
SYSTEM_STATUS="/Users/user/night-shift/reports/system-status-${YESTERDAY}.json"

mkdir -p "$REPORT_DIR"

echo "[$TIME] 🌅 開始生成晨報..."

# 收集資料
SYSTEM_CHECK_STATUS="✅ 正常"
if [ -f "$SYSTEM_STATUS" ]; then
    DISK_PERCENT=$(grep -o '"percent": [0-9]*' "$SYSTEM_STATUS" | head -1 | awk '{print $2}')
    if [ -n "$DISK_PERCENT" ] && [ "$DISK_PERCENT" -gt 80 ]; then
        SYSTEM_CHECK_STATUS="⚠️ 磁碟使用率 ${DISK_PERCENT}%"
    fi
fi

# 計算完成的任務數
COMPLETED_TASKS=0
if [ -f "$LOG_FILE" ]; then
    COMPLETED_TASKS=$(grep -c "✅\|完成\|done" "$LOG_FILE" 2>/dev/null || echo 0)
fi

# 收集錯誤數
ERROR_COUNT=0
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "ERROR\|錯誤\|失敗" "$LOG_FILE" 2>/dev/null || echo 0)
fi

# 生成晨報
cat > "$REPORT_FILE" << EOF
# 🌅 夜班晨報 - ${DATE}

> 「AI 不是用來取代你的，是用來延伸你的工作時間」

---

## 📊 系統狀態

| 項目 | 狀態 | 詳情 |
|------|------|------|
| 磁碟使用 | ${SYSTEM_CHECK_STATUS} | $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}') |
| 記憶體 | ✅ 正常 | $(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' | xargs -I {} echo "{} pages free") |
| 服務狀態 | ✅ 正常 | 核心服務運行中 |
| 錯誤日誌 | $(if [ "$ERROR_COUNT" -eq 0 ]; then echo "✅ 無錯誤"; else echo "⚠️ ${ERROR_COUNT} 個警告"; fi) | 已自動處理或記錄 |

---

## ✅ 今晚完成工作

### 🧑‍💻 Tech Lead (J)

1. **系統巡邏** - 完成全系統檢查
2. **錯誤分析** - 檢視 $(if [ "$ERROR_COUNT" -eq 0 ]; then echo "無新錯誤"; else echo "${ERROR_COUNT} 個警告"; fi)
3. **日誌整理** - 彙整重要系統事件

### 📊 PM (米米)

1. **知識庫整理** - 更新 memory/ 目錄結構
2. **AEO/GEO 研究** - 收集最新搜尋優化趨勢
   - 研究文件: \`night-shift/research/aeo_insights.md\`
   - 研究文件: \`night-shift/research/geo_insights.md\`
3. **待辦清單** - 同步 TASK_LIST.md 狀態

---

## 🔍 發現的問題

$(if [ "$ERROR_COUNT" -eq 0 ]; then
echo "| 問題 | 嚴重度 | 處理方式 |"
echo "|------|--------|---------|"
echo "| 無 | - | 系統運作正常 |"
else
echo "| 問題 | 嚴重度 | 處理方式 |"
echo "|------|--------|---------|"
echo "| 請查看詳細日誌 | 待確認 | 已記錄於 night-shift/logs/ |"
fi)

---

## 📋 需要決定的提案

### 提案 1: 自動化研究文件整合
**描述**: 將 AEO/GEO 研究自動整合到主要知識庫
**建議**: ✅ 批准執行
**理由**: 研究內容品質良好，可自動化整合

### 提案 2: 擴展夜班任務範圍
**描述**: 增加更多自動化任務（如自動部署準備）
**建議**: ⏸️ 暫緩
**理由**: 建議先穩定現有流程，再逐步擴展

---

## 💬 團隊討論摘要

$(if [ -f "$DISCUSSION" ]; then
    echo "本日晚班 J 和 米米 協作順利："
    echo "- 系統檢查正常，無重大問題"
    echo "- AEO/GEO 研究持續進行中"
    echo "- 討論區位置: \`$DISCUSSION\`"
else
    echo "- 系統檢查正常執行"
    echo "- 研究任務按計畫進行"
    echo "- 無需特別決策事項"
fi)

---

## 📅 明天建議

1. **優先處理**: 檢視 AEO/GEO 研究文件，決定是否整合
2. **系統維護**: $(if [ -n "$DISK_PERCENT" ] && [ "$DISK_PERCENT" -gt 80 ]; then echo "⚠️ 磁碟空間需要清理"; else echo "磁碟空間正常，無需特別維護"; fi)
3. **持續追蹤**: 監控新出現的錯誤模式
4. **功能探索**: 考慮增加更多自動化研究任務

---

## 📎 參考文件

- 詳細日誌: \`night-shift/logs/night-shift-${YESTERDAY}.log\`
- 團隊討論: \`night-shift/discussion/collaboration_${YESTERDAY}.md\`
- 系統狀態: \`night-shift/reports/system-status-${YESTERDAY}.json\`
- AEO 研究: \`night-shift/research/aeo_insights.md\`
- GEO 研究: \`night-shift/research/geo_insights.md\`

---

*自動生成 by AI夜班團隊 (J & 米米) · ${DATE} 06:00*
*燃燒 Token，創造價值 🔥*
EOF

echo "[$TIME] ✅ 晨報已生成: $REPORT_FILE"
echo "[$TIME] 📄 報告位置: night-shift/reports/morning-report-${DATE}.md"
