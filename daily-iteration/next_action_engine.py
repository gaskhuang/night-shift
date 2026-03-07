#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🎯 下一步行動推薦引擎 (Next Action Engine) v2.0

從第二大腦分析並推薦「下一步要做什麼」

資料來源:
1. 夜班晨報成果 (night-shift/reports/)
2. 長期待辦任務 (memory/TASK_LIST.md)
3. 第二大腦 (memory/second_brain.md, IDEA.md)
4. 昨日覆盤的明日意圖 (night-shift/evening/)
5. 當前能量狀態

使用方式:
    python3 next_action_engine.py --today          # 獲取今日推薦
    python3 next_action_engine.py --energy high    # 基於能量狀態推薦
    python3 next_action_engine.py --quick          # 快速任務推薦
    python3 next_action_engine.py --morning        # 08:30 晨間模式 (完整版)
"""

import os
import sys
import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from typing import List, Dict, Optional, Tuple

# 路徑設定
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")
MEMORY_DIR = Path("/Users/user/memory")
REPORTS_DIR = NIGHT_SHIFT_DIR / "reports"
EVENING_DIR = NIGHT_SHIFT_DIR / "evening"
RECOMMENDATIONS_DIR = NIGHT_SHIFT_DIR / "recommendations"
SOLUTIONS_DIR = NIGHT_SHIFT_DIR / "solutions"
OUTPUT_FILE = NIGHT_SHIFT_DIR / "daily-iteration" / "recommendation.md"

# 顏色輸出
class Colors:
    GREEN = '\033[92m'
    BLUE = '\033[94m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    CYAN = '\033[96m'
    BOLD = '\033[1m'
    END = '\033[0m'


def print_header(title: str):
    print(f"\n{Colors.CYAN}{'='*60}{Colors.END}")
    print(f"{Colors.BOLD}{title}{Colors.END}")
    print(f"{Colors.CYAN}{'='*60}{Colors.END}\n")


def get_today_str() -> str:
    return datetime.now().strftime("%Y-%m-%d")


def get_yesterday_str() -> str:
    return (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")


def read_file_safely(filepath: Path, max_lines: int = 100) -> str:
    """安全讀取檔案內容"""
    if not filepath.exists():
        return ""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()[:max_lines]
            return ''.join(lines)
    except Exception as e:
        return f"[讀取錯誤: {e}]"


def parse_morning_report() -> Dict:
    """解析夜班晨報"""
    today = get_today_str()
    yesterday = get_yesterday_str()
    
    # 嘗試找今天的晨報
    report_files = list(REPORTS_DIR.glob(f"morning-report*{today}*.md"))
    
    if not report_files:
        # 嘗試找昨天的
        report_files = list(REPORTS_DIR.glob(f"morning-report*{yesterday}*.md"))
    
    if not report_files:
        return {"found": False, "content": "", "summary": "尚未生成晨報"}
    
    content = read_file_safely(report_files[0])
    
    # 提取關鍵資訊
    summary = {
        "found": True,
        "content": content[:2000],
        "completed_work": [],
        "issues": [],
        "proposals": [],
        "high_priority_recs": 0,
        "solutions_count": 0
    }
    
    # 簡單解析完成的任務
    for line in content.split('\n'):
        if line.strip().startswith('- [x]') or line.strip().startswith('1.'):
            summary["completed_work"].append(line.strip())
        if '問題' in line or 'issue' in line.lower():
            summary["issues"].append(line.strip())
        if '高優先' in line or 'high' in line.lower():
            summary["high_priority_recs"] += 1
    
    return summary


def parse_evening_review() -> Dict:
    """解析昨日覆盤"""
    yesterday = get_yesterday_str()
    review_file = EVENING_DIR / f"{yesterday}_Evening.md"
    
    if not review_file.exists():
        return {"found": False, "tomorrow_intent": "", "energy": "unknown"}
    
    content = read_file_safely(review_file)
    
    # 提取明日意圖
    intent = ""
    energy = "unknown"
    
    lines = content.split('\n')
    for i, line in enumerate(lines):
        if '明天只能做一件事' in line or 'Tomorrow Intent' in line:
            # 找下一個非空行
            for j in range(i+1, min(i+5, len(lines))):
                if lines[j].strip() and not lines[j].strip().startswith('#'):
                    intent = lines[j].strip().replace('**', '')
                    break
        if '期望能量狀態' in line or '高能量' in line:
            if '[x]' in line or 'checked' in line.lower():
                if '高' in line:
                    energy = "high"
                elif '中' in line:
                    energy = "medium"
                elif '低' in line:
                    energy = "low"
    
    return {
        "found": True,
        "tomorrow_intent": intent,
        "energy": energy,
        "content_preview": content[:1000]
    }


def parse_task_list() -> List[Dict]:
    """解析待辦任務清單"""
    task_file = MEMORY_DIR / "TASK_LIST.md"
    
    if not task_file.exists():
        return []
    
    content = read_file_safely(task_file, max_lines=300)
    tasks = []
    
    current_priority = "normal"
    for line in content.split('\n'):
        # 偵測優先級區塊
        if 'P0' in line or '高優先' in line or '🔴' in line:
            current_priority = "high"
        elif 'P1' in line or '中優先' in line or '🟡' in line:
            current_priority = "medium"
        elif 'P2' in line or '低優先' in line or '🟢' in line:
            current_priority = "low"
        
        # 解析任務項目
        if line.strip().startswith('- [ ]') or line.strip().startswith('1.'):
            task_text = re.sub(r'^[-\d\.\[\]\s]+', '', line.strip())
            if task_text and len(task_text) > 3:
                tasks.append({
                    "text": task_text,
                    "priority": current_priority,
                    "raw": line.strip()
                })
    
    return tasks


def parse_second_brain() -> Dict:
    """解析第二大腦資料"""
    second_brain_file = MEMORY_DIR / "second_brain.md"
    idea_file = Path("/Users/user/IDEA.md")
    
    result = {
        "found": False,
        "active_projects": [],
        "ideas": [],
        "waiting_for": [],
        "next_actions": []
    }
    
    # 讀取 second_brain.md
    if second_brain_file.exists():
        content = read_file_safely(second_brain_file, max_lines=500)
        result["found"] = True
        
        # 提取進行中的專案
        for line in content.split('\n'):
            if '🚀' in line or '進行中' in line or '執行中' in line:
                project = line.strip().replace('##', '').replace('🚀', '').strip()
                if project:
                    result["active_projects"].append(project)
            if '等待' in line or 'waiting' in line.lower():
                result["waiting_for"].append(line.strip())
            if '下一步' in line or 'Next Action' in line:
                result["next_actions"].append(line.strip())
    
    # 讀取 IDEA.md
    if idea_file.exists():
        content = read_file_safely(idea_file, max_lines=300)
        for line in content.split('\n'):
            if '##' in line and ('想法' in line or 'Idea' in line or '專案' in line):
                idea = line.replace('##', '').strip()
                result["ideas"].append(idea)
    
    return result


def parse_night_shift_recommendations() -> List[Dict]:
    """解析夜班系統生成的推薦和解法"""
    yesterday = get_yesterday_str()
    
    rec_file = RECOMMENDATIONS_DIR / f"recommendations_{yesterday}.json"
    sol_file = SOLUTIONS_DIR / f"solutions_{yesterday}.json"
    
    recommendations = []
    
    # 讀取推薦
    if rec_file.exists():
        try:
            with open(rec_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
                recommendations = data.get("recommendations", [])
        except:
            pass
    
    # 讀取解法並關聯
    if sol_file.exists():
        try:
            with open(sol_file, 'r', encoding='utf-8') as f:
                solutions = json.load(f)
                for rec in recommendations:
                    rec_id = rec.get("id", "")
                    for sol in solutions:
                        if sol.get("recommendation_id") == rec_id:
                            rec["solution"] = sol
                            break
        except:
            pass
    
    return recommendations


def score_action(task: Dict, review: Dict, energy: str = "medium", 
                 second_brain: Dict = None, night_recs: List = None) -> int:
    """
    為行動打分 (1-100)
    
    評分維度:
    - 緊急度 (30%)
    - 影響力 (25%)
    - 可行性/能量匹配 (20%)
    - 與昨日意圖的關聯 (10%)
    - 與第二大腦關聯 (10%)
    - 夜班推薦權重 (5%)
    """
    score = 50  # 基礎分
    
    # 緊急度評分
    if task["priority"] == "high":
        score += 25
    elif task["priority"] == "medium":
        score += 15
    else:
        score += 5
    
    # 影響力評分 (基於關鍵字)
    high_impact_keywords = ['收入', '變現', '客戶', '銷售', 'deploy', '上線', '發布', '營收']
    medium_impact_keywords = ['優化', '改進', '整理', '更新', '研究']
    
    text_lower = task["text"].lower()
    if any(k in text_lower for k in high_impact_keywords):
        score += 25
    elif any(k in text_lower for k in medium_impact_keywords):
        score += 15
    
    # 能量匹配
    task_type = classify_task_type(task["text"])
    if energy == "high" and task_type == "rocket":
        score += 15
    elif energy == "medium" and task_type == "maintenance":
        score += 15
    elif energy == "low" and task_type == "quick":
        score += 20
    
    # 與昨日意圖關聯
    if review.get("tomorrow_intent"):
        intent_keywords = review["tomorrow_intent"].lower().split()
        if any(kw in text_lower for kw in intent_keywords if len(kw) > 2):
            score += 10
    
    # 與第二大腦關聯
    if second_brain:
        for project in second_brain.get("active_projects", []):
            if any(kw in text_lower for kw in project.lower().split() if len(kw) > 2):
                score += 10
                break
    
    # 夜班推薦權重
    if night_recs:
        for rec in night_recs:
            if rec.get("priority") == "high":
                rec_text = rec.get("title", "").lower()
                if any(kw in text_lower for kw in rec_text.split() if len(kw) > 2):
                    score += 5
                    break
    
    return min(score, 100)


def classify_task_type(task_text: str) -> str:
    """分類任務類型"""
    text_lower = task_text.lower()
    
    # 快速任務特徵
    if any(k in text_lower for k in ['審批', '確認', '回覆', '查看', '檢查', '簽核', 'email', '郵件']):
        return "quick"
    
    # 維護任務特徵
    if any(k in text_lower for k in ['整理', '備份', '更新', '同步', '清理', '歸檔']):
        return "maintenance"
    
    # 火箭任務特徵 (需要深度工作)
    if any(k in text_lower for k in ['開發', '設計', '架構', '戰略', '規劃', '重構', '優化核心', '思考']):
        return "rocket"
    
    # 成長型任務
    if any(k in text_lower for k in ['學習', '研究', '閱讀', '課程', '練習']):
        return "growth"
    
    return "maintenance"


def get_task_emoji(task_type: str) -> str:
    """獲取任務類型表情"""
    emojis = {
        "rocket": "🚀",
        "maintenance": "🔄",
        "quick": "⚡",
        "growth": "🌱"
    }
    return emojis.get(task_type, "📋")


def generate_next_actions(tasks: List[Dict], review: Dict, 
                          second_brain: Dict, night_recs: List,
                          energy: str = "medium") -> List[Dict]:
    """
    生成「下一步要做什麼」的推薦清單
    
    這是核心功能：結合所有資料源推薦下一步行動
    """
    
    # 為所有任務打分
    scored_tasks = []
    for task in tasks:
        score = score_action(task, review, energy, second_brain, night_recs)
        task_type = classify_task_type(task["text"])
        scored_tasks.append({
            **task,
            "score": score,
            "type": task_type,
            "emoji": get_task_emoji(task_type),
            "source": "task_list"
        })
    
    # 加入第二大腦中的下一步行動
    for action in second_brain.get("next_actions", [])[:3]:
        scored_tasks.append({
            "text": action,
            "priority": "medium",
            "score": 75,  # 第二大腦中的下一步通常很重要
            "type": classify_task_type(action),
            "emoji": "🧠",
            "source": "second_brain"
        })
    
    # 加入夜班推薦的高優先事項
    for rec in night_recs:
        if rec.get("priority") == "high":
            sol = rec.get("solution", {})
            action_text = rec.get("title", "")
            if sol and sol.get("solution_title"):
                action_text = f"{action_text} → {sol.get('solution_title')}"
            
            scored_tasks.append({
                "text": action_text,
                "priority": "high",
                "score": 85,  # 夜班高優先推薦
                "type": "rocket",
                "emoji": "🔮",
                "source": "night_shift",
                "solution": sol
            })
    
    # 按分數排序
    scored_tasks.sort(key=lambda x: x["score"], reverse=True)
    
    return scored_tasks[:5]  # 回傳 Top 5


def format_recommendation_md(recommendations: List[Dict], review: Dict, 
                              morning_report: Dict, second_brain: Dict,
                              night_recs: List, energy: str) -> str:
    """格式化推薦內容為 Markdown"""
    
    today = get_today_str()
    
    md = f"""# 🎯 今日行動推薦 - {today}

*生成時間: {datetime.now().strftime('%Y-%m-%d %H:%M')}*

> 💡 **從第二大腦分析，推薦下一步要做什麼**

---

## 📊 決策依據

| 資料來源 | 狀態 |
|---------|------|
| 🌙 夜班晨報 | {'✅ 已生成' if morning_report.get('found') else '⏳ 尚未生成'} |
| 📋 待辦任務 | {'✅ ' + str(len(parse_task_list())) + ' 個任務' if parse_task_list() else '⚠️ 無待辦'} |
| 🧠 第二大腦 | {'✅ ' + str(len(second_brain.get('active_projects', []))) + ' 個活躍專案' if second_brain.get('active_projects') else '⚠️ 無活躍專案'} |
| 🔮 夜班推薦 | {'✅ ' + str(len(night_recs)) + ' 條建議' if night_recs else '⚠️ 無推薦'} |

### 📝 昨日意圖
> {review.get('tomorrow_intent', '尚未設定')}

### ⚡ 當前能量設定
**{energy.upper()}** 模式

---

## 🏆 下一步要做什麼（TOP 3）

"""
    
    for i, rec in enumerate(recommendations[:3], 1):
        priority_label = {"high": "🔴 P0", "medium": "🟡 P1", "low": "🟢 P2"}.get(rec["priority"], "⚪")
        source_icon = {
            "task_list": "📋",
            "second_brain": "🧠",
            "night_shift": "🔮"
        }.get(rec.get("source", "task_list"), "📋")
        
        md += f"""### #{i} {rec['emoji']} {rec['text'][:60]}

| 屬性 | 內容 |
|------|------|
| **來源** | {source_icon} {rec.get('source', 'task_list').replace('_', ' ').title()} |
| **優先級** | {priority_label} |
| **類型** | {rec['type'].upper()} |
| **推薦分數** | {'⭐' * (rec['score'] // 20)} {rec['score']}/100 |
| **推薦原因** | {'與昨日意圖高度相關' if rec['score'] > 80 else '高影響力任務' if rec['score'] > 70 else '符合當前能量狀態'} |

"""
        # 如果有解法，添加解法
        if rec.get("solution"):
            sol = rec["solution"]
            md += f"""**💡 夜班建議解法：**
- {sol.get('solution_title', '暫無解法')}
- 預估時間: {sol.get('estimated_time', '未知')}
"""
        
        md += "\n---\n\n"
    
    # 低能量替代選項
    md += """## 🔄 如果能量不足...

當你覺得累或無法專注時，可以選擇:

"""
    
    quick_tasks = [r for r in recommendations if r["type"] == "quick"][:2]
    if quick_tasks:
        for task in quick_tasks:
            md += f"- ⚡ {task['text'][:50]}\n"
    else:
        md += "- ⚡ 整理今日郵件\n"
        md += "- ⚡ 回覆待回訊息\n"
    
    # 添加第二大腦洞察
    if second_brain.get("active_projects"):
        md += """
---

## 🧠 第二大腦洞察

### 進行中的專案
"""
        for project in second_brain["active_projects"][:3]:
            md += f"- 🚀 {project}\n"
    
    if second_brain.get("waiting_for"):
        md += """
### ⏳ 等待中
"""
        for item in second_brain["waiting_for"][:3]:
            md += f"- ⏳ {item[:60]}\n"
    
    # 夜班推薦摘要
    if night_recs:
        md += """
---

## 🔮 夜班系統推薦摘要

昨晚 AI 夜班團隊分析了您的數據，發現：

"""
        high_priority = [r for r in night_recs if r.get("priority") == "high"]
        if high_priority:
            md += f"**🔴 高優先事項 ({len(high_priority)} 個):**\n"
            for rec in high_priority[:2]:
                sol = rec.get("solution", {})
                md += f"- {rec.get('title', '')}\n"
                if sol:
                    md += f"  → 建議: {sol.get('solution_title', '暫無')}\n"
            md += "\n"
    
    md += """
---

## 📝 使用說明

1. **專注 #1 推薦**: 在最高能量時段執行最重要的事
2. **彈性調整**: 如果能量不符，選擇替代選項
3. **完成後標記**: 在 TASK_LIST.md 中標記 `- [x]`
4. **晚上覆盤**: 22:00 執行 `daily_review.sh`

---

*由 Next Action Engine v2.0 生成 | 與 Night Shift System 整合*
*資料來源: 第二大腦 + 夜班推薦 + 待辦清單*
"""
    
    return md


def format_telegram_message(recommendations: List[Dict], energy: str) -> str:
    """生成 Telegram 訊息格式"""
    today = get_today_str()
    
    msg = f"""🎯 <b>今日行動推薦</b> - {today}

<b>⚡ 能量模式:</b> {energy.upper()}

<b>🏆 下一步要做什麼：</b>

"""
    
    for i, rec in enumerate(recommendations[:3], 1):
        priority_emoji = {"high": "🔴", "medium": "🟡", "low": "🟢"}.get(rec["priority"], "⚪")
        msg += f"{i}. {priority_emoji} <b>{rec['text'][:40]}</b>\n"
        msg += f"   類型: {rec['emoji']} {rec['type'].upper()} | 分數: {rec['score']}/100\n\n"
    
    msg += "<i>詳細報告: night-shift/daily-iteration/recommendation.md</i>"
    
    return msg


def main():
    """主程式"""
    import argparse
    
    parser = argparse.ArgumentParser(description='下一步行動推薦引擎 v2.0')
    parser.add_argument('--today', action='store_true', help='獲取今日推薦')
    parser.add_argument('--morning', action='store_true', help='08:30 晨間模式 (完整版)')
    parser.add_argument('--energy', choices=['high', 'medium', 'low'], 
                        default='medium', help='當前能量狀態')
    parser.add_argument('--quick', action='store_true', help='只顯示快速任務')
    parser.add_argument('--output', '-o', type=str, help='輸出到指定檔案')
    parser.add_argument('--telegram', action='store_true', help='輸出 Telegram 格式')
    
    args = parser.parse_args()
    
    # 預設執行今日推薦
    if not any([args.today, args.quick, args.morning]):
        args.today = True
    
    # 晨間模式啟用完整功能
    if args.morning:
        args.today = True
    
    print_header("🎯 NEXT ACTION ENGINE v2.0 | 下一步行動推薦引擎")
    
    # 讀取資料
    print(f"{Colors.BLUE}📊 正在分析第二大腦...{Colors.END}\n")
    
    morning_report = parse_morning_report()
    evening_review = parse_evening_review()
    tasks = parse_task_list()
    second_brain = parse_second_brain()
    night_recs = parse_night_shift_recommendations()
    
    energy = args.energy
    if evening_review.get("energy") and evening_review["energy"] != "unknown":
        energy = evening_review["energy"]
        print(f"{Colors.GREEN}✓ 使用昨日設定的能量狀態: {energy}{Colors.END}")
    
    print(f"{Colors.GREEN}✓ 找到 {len(tasks)} 個待辦任務{Colors.END}")
    print(f"{Colors.GREEN}✓ 第二大腦: {len(second_brain.get('active_projects', []))} 個活躍專案{Colors.END}")
    print(f"{Colors.GREEN}✓ 夜班推薦: {len(night_recs)} 條建議{Colors.END}")
    print(f"{Colors.GREEN}✓ 夜班晨報: {'已生成' if morning_report['found'] else '尚未生成'}{Colors.END}")
    print(f"{Colors.GREEN}✓ 昨日覆盤: {'已填寫' if evening_review['found'] else '尚未填寫'}{Colors.END}")
    
    # 生成推薦
    print(f"\n{Colors.BLUE}🎯 正在計算最佳行動...{Colors.END}\n")
    
    recommendations = generate_next_actions(
        tasks, evening_review, second_brain, night_recs, energy
    )
    
    if not recommendations:
        print(f"{Colors.YELLOW}⚠️  目前沒有待辦任務，請檢查 TASK_LIST.md{Colors.END}")
        return
    
    # 顯示結果
    print_header("🏆 下一步要做什麼（推薦）")
    
    for i, rec in enumerate(recommendations[:3], 1):
        score_color = Colors.GREEN if rec["score"] >= 80 else Colors.YELLOW if rec["score"] >= 60 else Colors.RED
        print(f"{Colors.BOLD}#{i} {rec['emoji']} {rec['text'][:50]}{Colors.END}")
        print(f"   來源: {rec.get('source', 'task_list')} | 類型: {rec['type'].upper()} | 分數: {score_color}{rec['score']}/100{Colors.END}")
        if rec.get("solution"):
            print(f"   💡 {rec['solution'].get('solution_title', '')}")
        print()
    
    # 輸出到檔案
    output_path = Path(args.output) if args.output else OUTPUT_FILE
    md_content = format_recommendation_md(
        recommendations, evening_review, morning_report,
        second_brain, night_recs, energy
    )
    
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(md_content)
    
    print(f"{Colors.GREEN}✅ 完整推薦已儲存至: {output_path}{Colors.END}")
    
    # 輸出 Telegram 格式
    if args.telegram:
        telegram_msg = format_telegram_message(recommendations, energy)
        telegram_file = NIGHT_SHIFT_DIR / "daily-iteration" / "telegram_message.txt"
        with open(telegram_file, 'w', encoding='utf-8') as f:
            f.write(telegram_msg)
        print(f"{Colors.GREEN}✅ Telegram 訊息已儲存至: {telegram_file}{Colors.END}")
    
    print(f"\n{Colors.CYAN}💡 提示: 晚上 22:00 記得執行覆盤 → ./daily_review.sh{Colors.END}\n")


if __name__ == "__main__":
    main()
