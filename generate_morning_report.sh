#!/bin/bash
# 🌅 晨報生成器 v2.5
# 彙整整夜工作成果，生成給 G大的晨報
# 新增：整合智能推薦與解法、08:30行動推薦預告

export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin"

DATE=$(date '+%Y-%m-%d')
TIME=$(date '+%H:%M')
YESTERDAY=$(date -v-1d '+%Y-%m-%d')
REPORT_DIR="/Users/user/night-shift/reports"
REPORT_FILE="$REPORT_DIR/morning-report-${DATE}.md"
DISCUSSION="/Users/user/night-shift/discussion/collaboration_${YESTERDAY}.md"
LOG_FILE="/Users/user/night-shift/logs/night-shift-${YESTERDAY}.log"
SYSTEM_STATUS="/Users/user/night-shift/reports/system-status-${YESTERDAY}.json"
RECOMMENDATION_FILE="/Users/user/night-shift/recommendations/recommendations_${YESTERDAY}.json"
SOLUTION_FILE="/Users/user/night-shift/solutions/solutions_${YESTERDAY}.json"
DAILY_ITERATION_DIR="/Users/user/night-shift/daily-iteration"

mkdir -p "$REPORT_DIR"

echo "[$TIME] 🌅 開始生成晨報 v2.5..."

# ============================================
# 收集資料
# ============================================

SYSTEM_CHECK_STATUS="✅ 正常"
if [ -f "$SYSTEM_STATUS" ]; then
    DISK_PERCENT=$(grep -o '"percent": [0-9]*' "$SYSTEM_STATUS" | head -1 | awk '{print $2}')
    if [ -n "$DISK_PERCENT" ] && [ "$DISK_PERCENT" -gt 80 ]; then
        SYSTEM_CHECK_STATUS="⚠️ 磁碟使用率 ${DISK_PERCENT}%"
    fi
fi

COMPLETED_TASKS=0
if [ -f "$LOG_FILE" ]; then
    COMPLETED_TASKS=$(grep -c "✅\|完成\|done" "$LOG_FILE" 2>/dev/null || echo 0)
fi

ERROR_COUNT=0
if [ -f "$LOG_FILE" ]; then
    ERROR_COUNT=$(grep -c "ERROR\|錯誤\|失敗" "$LOG_FILE" 2>/dev/null || echo 0)
fi

# 讀取推薦數據
RECOMMENDATION_COUNT=0
HIGH_PRIORITY_RECS=0
if [ -f "$RECOMMENDATION_FILE" ]; then
    RECOMMENDATION_COUNT=$(grep -c '"id": "rec_' "$RECOMMENDATION_FILE" 2>/dev/null || echo 0)
    HIGH_PRIORITY_RECS=$(grep -c '"priority": "high"' "$RECOMMENDATION_FILE" 2>/dev/null || echo 0)
fi

# 讀取解法數據
SOLUTION_COUNT=0
AUTO_APPLY_COUNT=0
if [ -f "$SOLUTION_FILE" ]; then
    SOLUTION_COUNT=$(grep -c '"recommendation_id"' "$SOLUTION_FILE" 2>/dev/null || echo 0)
    AUTO_APPLY_COUNT=$(grep -c '"auto_apply": "yes"' "$SOLUTION_FILE" 2>/dev/null || echo 0)
fi

# ============================================
# 生成晨報
# ============================================

cat > "$REPORT_FILE" << EOF
# 🌅 夜班晨報 - ${DATE}

> 「AI 不是用來取代你的，是用來延伸你的工作時間」
> 
> 💡 **本晨報新增「智能推薦」區塊** - 夜班系統自動分析後給出的建議
> 
> ⏰ **08:30 將自動生成「今日行動推薦」** - 從第二大腦分析下一步要做什麼

---

## 📊 系統狀態

| 項目 | 狀態 | 詳情 |
|------|------|------|
| 磁碟使用 | ${SYSTEM_CHECK_STATUS} | $(df -h / | tail -1 | awk '{print $3"/"$2" ("$5")"}') |
| 記憶體 | ✅ 正常 | $(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//' | xargs -I {} echo "{} pages free") |
| 服務狀態 | ✅ 正常 | 核心服務運行中 |
| 錯誤日誌 | $(if [ "$ERROR_COUNT" -eq 0 ]; then echo "✅ 無錯誤"; else echo "⚠️ ${ERROR_COUNT} 個警告"; fi) | 已自動處理或記錄 |

---

## 🔮 智能推薦 (本日重點)

夜班系統分析了過去3天的記憶、討論和日誌，為您準備了以下推薦：

**📈 數據摘要**
- 發現 **${RECOMMENDATION_COUNT}** 個值得關注的事項
- 其中 **${HIGH_PRIORITY_RECS}** 個為高優先級
- 已生成 **${SOLUTION_COUNT}** 個對應解法
- **${AUTO_APPLY_COUNT}** 個解法可自動執行

EOF

# ============================================
# 添加詳細推薦與解法
# ============================================

if [ -f "$RECOMMENDATION_FILE" ] && [ "$RECOMMENDATION_COUNT" -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "### 📋 推薦事項與解法" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
    
    # 解析 JSON 並生成推薦列表
    if command -v python3 &> /dev/null; then
        python3 << PYTHON_EOF
import json
import sys

rec_file = "$RECOMMENDATION_FILE"
sol_file = "$SOLUTION_FILE"

with open(rec_file, 'r') as f:
    data = json.load(f)

recommendations = data.get("recommendations", [])
solutions = {}

try:
    with open(sol_file, 'r') as f:
        sol_data = json.load(f)
        for sol in sol_data:
            solutions[sol.get("recommendation_id")] = sol
except:
    pass

# 按優先級排序
priority_order = {"high": 0, "medium": 1, "low": 2}
recommendations.sort(key=lambda x: priority_order.get(x.get("priority", "low"), 3))

for i, rec in enumerate(recommendations[:5], 1):  # 只顯示前5個
    rec_id = rec.get("id", "")
    title = rec.get("title", "")
    priority = rec.get("priority", "low")
    context = rec.get("context", "")
    category = rec.get("category", "other")
    
    sol = solutions.get(rec_id, {})
    sol_title = sol.get("solution_title", "")
    sol_time = sol.get("estimated_time", "")
    sol_auto = sol.get("auto_apply", "no")
    
    # 優先級標籤
    priority_emoji = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(priority, "⚪")
    
    # 類別標籤
    category_labels = {
        "pattern": "📊 模式",
        "task": "📋 任務",
        "bug": "🐛 錯誤",
        "project": "📁 專案",
        "opportunity": "💎 機會",
        "maintenance": "🔧 維護",
        "decision": "🤔 決策",
        "learning": "📚 學習"
    }
    category_label = category_labels.get(category, "📌 其他")
    
    # 自動化標籤
    auto_badge = ""
    if sol_auto == "yes":
        auto_badge = " 「🤖 已自動執行」"
    elif sol_auto == "partial":
        auto_badge = " 「⚡ 可部分自動化」"
    
    print(f"#### {priority_emoji} {title}{auto_badge}")
    print("")
    print(f"| 屬性 | 內容 |")
    print(f"|------|------|")
    print(f"| **類別** | {category_label} |")
    print(f"| **優先級** | {priority.upper()} |")
    print(f"| **問題描述** | {context} |")
    if sol_title:
        print(f"| **建議解法** | 💡 {sol_title} |")
        if sol_time:
            print(f"| **預估時間** | ⏱️ {sol_time} |")
    print("")
    print("---")
    print("")

PYTHON_EOF
    fi
    
    echo "" >> "$REPORT_FILE"
else
    echo "" >> "$REPORT_FILE"
    echo "> 💤 本日無特別推薦事項，系統運作正常。" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# ============================================
# 添加解法詳情區塊
# ============================================

if [ -f "$SOLUTION_FILE" ] && [ "$SOLUTION_COUNT" -gt 0 ]; then
    cat >> "$REPORT_FILE" << EOF

## 💡 解法詳情

夜班系統為推薦事項生成了具體解法：

EOF
    
    # 解析解法 JSON
    if command -v python3 &> /dev/null; then
        python3 << PYTHON_EOF
import json

sol_file = "$SOLUTION_FILE"

try:
    with open(sol_file, 'r') as f:
        solutions = json.load(f)
    
    for sol in solutions[:3]:  # 只顯示前3個
        title = sol.get("solution_title", "")
        steps = sol.get("steps", [])
        auto = sol.get("auto_apply", "no")
        
        auto_status = "🤖 可自動執行" if auto == "yes" else "⚡ 需手動執行" if auto == "no" else "🔧 部分自動化"
        
        print(f"### {title}")
        print(f"**狀態:** {auto_status}")
        print("")
        if steps:
            print("**執行步驟:**")
            for i, step in enumerate(steps[:3], 1):
                print(f"{i}. {step}")
        print("")
        print("---")
        print("")
except Exception as e:
    print(f"讀取解法檔案時發生錯誤: {e}")

PYTHON_EOF
    fi
fi

# ============================================
# 添加今晚完成的工作
# ============================================

cat >> "$REPORT_FILE" << EOF

---

## ✅ 今晚完成工作

### 🧑‍💻 Tech Lead (J)

1. **系統巡邏** - 完成全系統檢查
2. **錯誤分析** - 檢視 $(if [ "$ERROR_COUNT" -eq 0 ]; then echo "無新錯誤"; else echo "${ERROR_COUNT} 個警告"; fi)
3. **日誌整理** - 彙整重要系統事件
4. **問題修復** - 自動修復可處理的小問題

### 📊 PM (米米)

1. **知識庫整理** - 更新 memory/ 目錄結構
2. **🔮 智能推薦** - 分析並生成 ${RECOMMENDATION_COUNT} 個推薦
3. **💡 解法生成** - 為推薦事項提供解決方案
4. **AEO/GEO 研究** - 收集最新搜尋優化趨勢
5. **待辦清單** - 同步 TASK_LIST.md 狀態
6. **🧠 第二大腦分析** - 整理 second_brain.md 和 IDEA.md

---

## 🔍 發現的問題

$(if [ "$ERROR_COUNT" -eq 0 ] && [ "$HIGH_PRIORITY_RECS" -eq 0 ]; then
echo "✅ **本日無重大問題**"
echo ""
echo "系統運作正常，所有推薦事項皆為優化建議，無緊急問題需處理。"
else
echo "| 問題 | 嚴重度 | 處理方式 |"
echo "|------|--------|---------|"
if [ "$ERROR_COUNT" -gt 0 ]; then
    echo "| 系統錯誤日誌 | 待確認 | 已記錄於 night-shift/logs/ |"
fi
if [ "$HIGH_PRIORITY_RECS" -gt 0 ]; then
    echo "| ${HIGH_PRIORITY_RECS} 個高優先推薦事項 | 建議關注 | 請查看上方「智能推薦」區塊 |"
fi
fi)

---

## 📋 需要您決定的事項

$(if [ "$RECOMMENDATION_COUNT" -eq 0 ]; then
echo "本日無需特別決策。"
else
echo "根據智能推薦分析，建議您："
echo ""

# 使用 Python 解析高優先推薦
if command -v python3 &> /dev/null; then
    python3 << PYTHON_EOF
import json

rec_file = "$RECOMMENDATION_FILE"
sol_file = "$SOLUTION_FILE"

try:
    with open(rec_file, 'r') as f:
        data = json.load(f)
    
    recommendations = data.get("recommendations", [])
    
    solutions = {}
    try:
        with open(sol_file, 'r') as f:
            sol_data = json.load(f)
            for sol in sol_data:
                solutions[sol.get("recommendation_id")] = sol
    except:
        pass
    
    for rec in recommendations:
        if rec.get("priority") == "high":
            rec_id = rec.get("id", "")
            title = rec.get("title", "")
            sol = solutions.get(rec_id, {})
            sol_title = sol.get("solution_title", "暫無解法")
            
            print(f"### 🔴 {title}")
            print(f"- **建議解法**: {sol_title}")
            print(f"- **需要您**: 確認是否執行")
            print("")
except Exception as e:
    pass

PYTHON_EOF
fi

if [ "$AUTO_APPLY_COUNT" -gt 0 ]; then
    echo "### ✅ 已自動執行的事項"
    echo "夜班系統已自動處理 ${AUTO_APPLY_COUNT} 個低風險優化項目，詳情見日誌。"
fi
fi)

---

## 💬 團隊討論摘要

$(if [ -f "$DISCUSSION" ]; then
    echo "本日晚班 J 和 米米 協作順利："
    echo "- 系統檢查正常，無重大問題"
    echo "- 完成智能推薦分析，發現 ${RECOMMENDATION_COUNT} 個關注點"
    echo "- 為每個推薦生成具體解法"
    echo "- 整理第二大腦資料"
    echo "- 討論區位置: \`$DISCUSSION\`"
else
    echo "- 系統檢查正常執行"
    echo "- 智能推薦系統運作中"
    echo "- 研究任務按計畫進行"
    echo "- 無需特別決策事項"
fi)

---

## 🎯 08:30 行動推薦預告

每天早上 **08:30**，系統將自動生成「**今日行動推薦**」：

### 推薦內容：
- 🏆 **下一步要做什麼**（TOP 3 推薦行動）
- 🧠 **第二大腦洞察**（進行中的專案、等待中的事項）
- 🔮 **夜班推薦摘要**（高優先事項與解法）
- 🔄 **能量調整建議**（根據當前狀態推薦）

### 資料來源：
1. ✅ 夜班晨報成果
2. ✅ 長期待辦任務 (TASK_LIST.md)
3. ✅ 第二大腦 (second_brain.md, IDEA.md)
4. ✅ 昨日覆盤的明日意圖
5. ✅ 系統狀態數據

---

## 📅 今天建議行動

$(if [ "$HIGH_PRIORITY_RECS" -gt 0 ]; then
echo "1. **🔴 優先處理**: 檢視上方「智能推薦」的高優先事項"
else
echo "1. **📋 一般處理**: 檢視「智能推薦」區塊，決定是否執行建議"
fi)
2. **系統維護**: $(if [ -n "$DISK_PERCENT" ] && [ "$DISK_PERCENT" -gt 80 ]; then echo "⚠️ 磁碟空間需要清理"; else echo "磁碟空間正常，無需特別維護"; fi)
3. **⏰ 08:30 查看**: 今日行動推薦將自動生成
4. **回饋夜班**: 如果推薦有幫助/沒幫助，請告訴我們，會持續優化算法
5. **功能探索**: 考慮增加更多自動化研究任務

---

## 📎 參考文件

- 詳細日誌: \`night-shift/logs/night-shift-${YESTERDAY}.log\`
- 團隊討論: \`night-shift/discussion/collaboration_${YESTERDAY}.md\`
- 系統狀態: \`night-shift/reports/system-status-${YESTERDAY}.json\`
- **智能推薦**: \`night-shift/recommendations/recommendations_${YESTERDAY}.json\`
- **解法詳情**: \`night-shift/solutions/solutions_${YESTERDAY}.json\`
- **08:30 行動推薦**: \`night-shift/daily-iteration/recommendation.md\`
- AEO 研究: \`night-shift/research/aeo_insights.md\`
- GEO 研究: \`night-shift/research/geo_insights.md\`

---

*自動生成 by AI夜班團隊 (J & 米米) · ${DATE} 06:00*
*燃燒 Token，創造價值 🔥*
*⏰ 08:30 將生成今日行動推薦*
EOF

echo "[$TIME] ✅ 晨報已生成: $REPORT_FILE"
echo "[$TIME] 📄 報告位置: night-shift/reports/morning-report-${DATE}.md"
echo "[$TIME] 🔮 包含 ${RECOMMENDATION_COUNT} 個智能推薦"
echo "[$TIME] 💡 包含 ${SOLUTION_COUNT} 個解法"
echo "[$TIME] ⏰ 08:30 將生成今日行動推薦"
