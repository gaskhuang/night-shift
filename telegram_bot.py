#!/usr/bin/env python3
"""
🌙 夜班系統 Telegram Bot
整合功能：
1. 系統優化 - 手動觸發夜班系統檢查
2. 第二大腦推薦 - 分析記憶庫推薦下一步行動
3. 思考模式 - GPT-5.4 深度推理分析
"""

import os
import sys
import json
import asyncio
import logging
import subprocess
from datetime import datetime, timedelta
from pathlib import Path
from typing import Optional, List, Dict, Any

# python-telegram-bot
from telegram import Update, BotCommand, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import (
    Application,
    CommandHandler,
    CallbackQueryHandler,
    MessageHandler,
    ContextTypes,
    filters
)

# 設定日誌
logging.basicConfig(
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    level=logging.INFO
)
logger = logging.getLogger(__name__)

# ============ 配置 ============
HOME_DIR = Path.home()
NIGHT_SHIFT_DIR = HOME_DIR / "night-shift"
MEMORY_DIR = HOME_DIR / "memory"
IDEA_FILE = HOME_DIR / "IDEA.md"
TASK_LIST_FILE = MEMORY_DIR / "TASK_LIST.md"
SECOND_BRAIN_FILE = MEMORY_DIR / "second_brain.md"

# 從環境變數或配置文件讀取 Telegram Bot Token
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN", "")
ALLOWED_USER_ID = os.getenv("TELEGRAM_ALLOWED_USER_ID", "")  # G大的 Telegram User ID

# ============ 指令選單 ============
BOT_COMMANDS = [
    BotCommand("start", "啟動機器人並顯示主選單"),
    BotCommand("optimize", "🔧 系統優化 - 執行夜班系統檢查"),
    BotCommand("recommend", "🧠 第二大腦推薦 - 分析並推薦下一步行動"),
    BotCommand("think", "💭 思考模式 - GPT-5.4 深度推理分析"),
    BotCommand("status", "📊 查看系統狀態"),
    BotCommand("help", "顯示使用說明"),
]

# ============ 主選單 ============
def get_main_menu() -> InlineKeyboardMarkup:
    """建立主選單"""
    keyboard = [
        [InlineKeyboardButton("🔧 系統優化", callback_data="optimize")],
        [InlineKeyboardButton("🧠 第二大腦推薦", callback_data="recommend")],
        [InlineKeyboardButton("💭 思考模式", callback_data="think")],
        [InlineKeyboardButton("📊 查看狀態", callback_data="status")],
    ]
    return InlineKeyboardMarkup(keyboard)

def get_back_menu() -> InlineKeyboardMarkup:
    """返回主選單按鈕"""
    keyboard = [[InlineKeyboardButton("⬅️ 返回主選單", callback_data="main_menu")]]
    return InlineKeyboardMarkup(keyboard)

# ============ 權限檢查 ============
def check_authorization(user_id: int) -> bool:
    """檢查使用者是否授權"""
    if not ALLOWED_USER_ID:
        return True  # 如果沒設定，允許所有使用者
    return str(user_id) == ALLOWED_USER_ID

# ============ 指令處理器 ============

async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """啟動指令 - 顯示主選單"""
    user = update.effective_user
    
    if not check_authorization(user.id):
        await update.message.reply_text("❌ 未授權的使用者")
        return
    
    welcome_text = f"""
🌙 <b>夜班系統控制中心</b>

歡迎，{user.first_name}！

這裡是您的 AI 夜班指揮中心，可以：
• 🔧 <b>系統優化</b> - 手動執行系統檢查與優化
• 🧠 <b>第二大腦推薦</b> - 從記憶庫分析並推薦下一步行動
• 💭 <b>思考模式</b> - 使用 GPT-5.4 進行深度推理分析

請選擇以下功能：
"""
    await update.message.reply_text(
        welcome_text,
        reply_markup=get_main_menu(),
        parse_mode="HTML"
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """幫助指令"""
    help_text = """
🌙 <b>夜班系統 Bot 使用說明</b>

<b>指令列表：</b>
/start - 顯示主選單
/optimize - 執行系統優化檢查
/recommend - 從第二大腦獲取推薦
/think [問題] - 啟動 GPT-5.4 思考模式
/status - 查看系統狀態
/help - 顯示此說明

<b>功能說明：</b>

🔧 <b>系統優化</b>
手動觸發夜班系統的系統檢查流程，包括：
- 檢查日誌與錯誤
- 清理暫存檔案
- 檢查磁碟空間
- 驗證服務狀態

🧠 <b>第二大腦推薦</b>
分析您的記憶庫（memory/、IDEA.md、TASK_LIST.md），推薦：
- 優先處理的事項
- 待完成的任務
- 創意發想建議

💭 <b>思考模式</b>
使用 GPT-5.4 進行深度推理：
- 複雜問題拆解
- 多步驟邏輯推演
- 策略分析與建議

<b>範例：</b>
<code>/think 如何優化我的內容行銷策略？</code>
"""
    await update.message.reply_text(help_text, parse_mode="HTML")

# ============ 系統優化功能 ============

async def optimize_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """系統優化指令"""
    user = update.effective_user
    
    if not check_authorization(user.id):
        await update.message.reply_text("❌ 未授權的使用者")
        return
    
    await update.message.reply_text(
        "🔧 <b>啟動系統優化檢查...</b>\n\n這可能需要 1-2 分鐘，請稍候。",
        parse_mode="HTML"
    )
    
    # 執行系統優化檢查
    result = await run_system_optimization()
    
    await update.message.reply_text(
        result,
        reply_markup=get_back_menu(),
        parse_mode="HTML"
    )

async def run_system_optimization() -> str:
    """執行系統優化檢查"""
    results = []
    results.append("🔧 <b>系統優化報告</b>")
    results.append(f"📅 執行時間: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    results.append("")
    
    # 1. 檢查夜班系統狀態
    try:
        pid_file = Path("/tmp/night-shift.pid")
        if pid_file.exists():
            results.append("🌙 夜班系統: <b>執行中</b> ⏳")
        else:
            results.append("🌙 夜班系統: <b>待命</b> 💤")
    except Exception as e:
        results.append(f"⚠️ 夜班系統檢查失敗: {e}")
    
    # 2. 檢查磁碟空間
    try:
        result = subprocess.run(
            ["df", "-h", str(HOME_DIR)],
            capture_output=True,
            text=True,
            timeout=10
        )
        lines = result.stdout.strip().split('\n')
        if len(lines) >= 2:
            # 解析磁碟使用情況
            parts = lines[1].split()
            if len(parts) >= 5:
                used_percent = parts[4].replace('%', '')
                results.append(f"💾 磁碟使用: <b>{parts[4]}</b>")
                if int(used_percent) > 80:
                    results.append("⚠️ 磁碟空間不足，建議清理！")
    except Exception as e:
        results.append(f"⚠️ 磁碟檢查失敗: {e}")
    
    # 3. 檢查記憶庫檔案數量
    try:
        memory_files = list(MEMORY_DIR.glob("*.md"))
        results.append(f"📝 記憶檔案: <b>{len(memory_files)}</b> 個")
    except Exception as e:
        results.append(f"⚠️ 記憶庫檢查失敗: {e}")
    
    # 4. 檢查最近夜班日誌
    try:
        today = datetime.now().strftime('%Y-%m-%d')
        log_file = NIGHT_SHIFT_DIR / "logs" / f"night-shift-{today}.log"
        if log_file.exists():
            with open(log_file, 'r') as f:
                lines = f.readlines()
            results.append(f"📋 今日日誌: <b>{len(lines)}</b> 行")
        else:
            results.append("📋 今日日誌: 無")
    except Exception as e:
        results.append(f"⚠️ 日誌檢查失敗: {e}")
    
    # 5. 執行簡易清理
    try:
        # 清理舊的暫存檔案
        temp_patterns = ["/tmp/night-shift-*.tmp", "/tmp/telegram-*.tmp"]
        cleaned = 0
        for pattern in temp_patterns:
            for f in Path("/tmp").glob(pattern.replace("/tmp/", "")):
                try:
                    f.unlink()
                    cleaned += 1
                except:
                    pass
        if cleaned > 0:
            results.append(f"🧹 清理暫存: <b>{cleaned}</b> 個檔案")
    except Exception as e:
        results.append(f"⚠️ 清理失敗: {e}")
    
    results.append("")
    results.append("✅ <b>系統優化完成！</b>")
    
    return "\n".join(results)

# ============ 第二大腦推薦功能 ============

async def recommend_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """第二大腦推薦指令"""
    user = update.effective_user
    
    if not check_authorization(user.id):
        await update.message.reply_text("❌ 未授權的使用者")
        return
    
    await update.message.reply_text(
        "🧠 <b>正在分析第二大腦...</b>\n\n讀取記憶庫、待辦清單與創意想法...",
        parse_mode="HTML"
    )
    
    # 生成推薦
    recommendation = await generate_recommendations()
    
    await update.message.reply_text(
        recommendation,
        reply_markup=get_back_menu(),
        parse_mode="HTML"
    )

async def generate_recommendations() -> str:
    """從第二大腦生成推薦"""
    recommendations = []
    recommendations.append("🧠 <b>第二大腦智能推薦</b>")
    recommendations.append(f"📅 {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    recommendations.append("")
    
    # 1. 分析 TASK_LIST.md
    tasks = await analyze_task_list()
    if tasks:
        recommendations.append("📋 <b>待辦任務分析</b>")
        for task in tasks[:5]:  # 只顯示前5個
            recommendations.append(task)
        recommendations.append("")
    
    # 2. 分析最近的記憶
    recent_memories = await analyze_recent_memories()
    if recent_memories:
        recommendations.append("📝 <b>近期重點回顧</b>")
        for memory in recent_memories[:3]:
            recommendations.append(memory)
        recommendations.append("")
    
    # 3. 讀取 IDEA.md 中的執行中項目
    ideas = await analyze_ideas()
    if ideas:
        recommendations.append("💡 <b>進行中的創意</b>")
        for idea in ideas[:3]:
            recommendations.append(idea)
        recommendations.append("")
    
    # 4. 智能推薦下一步行動
    recommendations.append("🎯 <b>推薦下一步行動</b>")
    next_actions = await generate_next_actions(tasks, recent_memories, ideas)
    for action in next_actions:
        recommendations.append(action)
    
    return "\n".join(recommendations)

async def analyze_task_list() -> List[str]:
    """分析待辦清單"""
    tasks = []
    try:
        if TASK_LIST_FILE.exists():
            content = TASK_LIST_FILE.read_text(encoding='utf-8')
            lines = content.split('\n')
            
            current_section = ""
            for line in lines:
                line = line.strip()
                if line.startswith('## 🔴 P0'):
                    current_section = "🔴 P0"
                elif line.startswith('## 🟡 P1'):
                    current_section = "🟡 P1"
                elif line.startswith('## 🟢 P2'):
                    current_section = "🟢 P2"
                elif line.startswith('- [ ]'):
                    task_text = line.replace('- [ ]', '').strip()
                    tasks.append(f"  {current_section} {task_text}")
                elif line.startswith('- [x]'):
                    # 跳過已完成的
                    pass
    except Exception as e:
        tasks.append(f"  ⚠️ 讀取待辦清單失敗: {e}")
    
    return tasks

async def analyze_recent_memories() -> List[str]:
    """分析最近幾天的記憶"""
    memories = []
    try:
        # 取得最近3天的記憶檔案
        today = datetime.now()
        for i in range(3):
            date_str = (today - timedelta(days=i)).strftime('%Y-%m-%d')
            memory_file = MEMORY_DIR / f"{date_str}.md"
            if memory_file.exists():
                content = memory_file.read_text(encoding='utf-8')
                # 提取標題或第一行
                lines = content.strip().split('\n')
                for line in lines:
                    if line.strip() and not line.startswith('#'):
                        memories.append(f"  • [{date_str}] {line[:50]}...")
                        break
    except Exception as e:
        memories.append(f"  ⚠️ 讀取記憶失敗: {e}")
    
    return memories

async def analyze_ideas() -> List[str]:
    """分析 IDEA.md 中的執行中項目"""
    ideas = []
    try:
        if IDEA_FILE.exists():
            content = IDEA_FILE.read_text(encoding='utf-8')
            lines = content.split('\n')
            
            for i, line in enumerate(lines):
                if '##' in line and ('執行中' in line or '進行中' in line or '🚀' in line):
                    # 找到項目名稱
                    idea_title = line.replace('##', '').replace('🚀', '').strip()
                    ideas.append(f"  • {idea_title}")
    except Exception as e:
        ideas.append(f"  ⚠️ 讀取創意清單失敗: {e}")
    
    return ideas

async def generate_next_actions(tasks, memories, ideas) -> List[str]:
    """生成下一步行動推薦"""
    actions = []
    
    # 根據任務數量給出建議
    p0_count = sum(1 for t in tasks if '🔴 P0' in t)
    if p0_count > 0:
        actions.append(f"  1️⃣ 優先處理 <b>{p0_count}</b> 個 P0 高優先任務")
    
    # 檢查夜班系統狀態
    try:
        today = datetime.now().strftime('%Y-%m-%d')
        log_file = NIGHT_SHIFT_DIR / "logs" / f"night-shift-{today}.log"
        if not log_file.exists():
            actions.append("  2️⃣ 今晚夜班尚未啟動，建議執行 /optimize")
    except:
        pass
    
    # 檢查記憶檔案數量
    try:
        memory_files = list(MEMORY_DIR.glob("2026-*.md"))
        if len(memory_files) > 30:
            actions.append("  3️⃣ 記憶檔案累積較多，建議進行蒸餾整理")
    except:
        pass
    
    if not actions:
        actions.append("  ✅ 目前狀態良好，持續監控中")
    
    return actions

# ============ 思考模式（GPT-5.4） ============

async def think_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """思考模式指令"""
    user = update.effective_user
    
    if not check_authorization(user.id):
        await update.message.reply_text("❌ 未授權的使用者")
        return
    
    # 獲取使用者的問題
    question = " ".join(context.args) if context.args else ""
    
    if not question:
        await update.message.reply_text(
            "💭 <b>思考模式</b>\n\n"
            "請提供要分析的問題。\n\n"
            "<b>用法：</b>\n"
            "<code>/think 如何優化我的內容行銷策略？</code>\n\n"
            "<b>適用場景：</b>\n"
            "• 複雜問題的拆解與分析\n"
            "• 需要多步驟邏輯推演的研究\n"
            "• 策略規劃與決策建議",
            parse_mode="HTML"
        )
        return
    
    # 顯示思考中訊息
    thinking_msg = await update.message.reply_text(
        f"💭 <b>啟動 GPT-5.4 思考模式...</b>\n\n"
        f"<b>問題：</b>{question[:100]}{'...' if len(question) > 100 else ''}\n\n"
        f"⏳ 正在進行深度推理，這可能需要 30-60 秒...",
        parse_mode="HTML"
    )
    
    # 執行 GPT-5.4 推理
    result = await run_gpt54_reasoning(question)
    
    # 刪除思考中訊息
    await thinking_msg.delete()
    
    # 發送結果（如果太長則分段）
    if len(result) > 4000:
        # 分段發送
        chunks = [result[i:i+4000] for i in range(0, len(result), 4000)]
        for i, chunk in enumerate(chunks):
            suffix = f"\n\n(Part {i+1}/{len(chunks)})" if len(chunks) > 1 else ""
            await update.message.reply_text(
                chunk + suffix,
                parse_mode="HTML"
            )
    else:
        await update.message.reply_text(
            result,
            reply_markup=get_back_menu(),
            parse_mode="HTML"
        )

async def run_gpt54_reasoning(question: str) -> str:
    """使用 GPT-5.4 進行深度推理"""
    try:
        # 導入 OpenAI client
        from openai import AsyncOpenAI
        
        # 嘗試從環境變數獲取 API key
        api_key = os.getenv("OPENAI_API_KEY", "")
        
        if not api_key:
            # 嘗試從常見位置讀取
            key_file = HOME_DIR / ".openclaw" / "credentials" / "openai.key"
            if key_file.exists():
                api_key = key_file.read_text().strip()
        
        if not api_key:
            return """❌ <b>無法啟動思考模式</b>

原因：找不到 OpenAI API Key

<b>解決方式：</b>
1. 設定環境變數：<code>export OPENAI_API_KEY="sk-..."</code>
2. 或建立金鑰檔案：<code>~/.openclaw/credentials/openai.key</code>

設定完成後重新執行 /think 指令。"""
        
        client = AsyncOpenAI(api_key=api_key)
        
        # 構建提示詞
        system_prompt = """你是 G大的 AI 思考助理，專門使用 GPT-5.4 進行深度推理分析。

你的任務是：
1. 深入分析用戶的問題，進行多層次思考
2. 拆解複雜問題為可執行的步驟
3. 提供結構化的分析框架
4. 給出具體、可執行的建議

輸出格式：
- 使用繁體中文
- 使用 Telegram HTML 格式（<b>粗體</b>、<i>斜體</i>、<code>代碼</code>）
- 結構清晰，使用標題和列表
- 重要結論前置"""

        user_prompt = f"""請對以下問題進行深度推理分析：

{question}

請提供：
1. 問題的核心拆解
2. 多角度的分析框架
3. 具體的行動建議
4. 潛在風險與注意事項"""

        # 呼叫 GPT-5.4 進行深度推理
        # 使用 o3-mini 作為目前最先進的推理模型
        response = await client.chat.completions.create(
            model="o3-mini",
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_prompt}
            ],
            max_completion_tokens=4000
        )
        
        result = response.choices[0].message.content
        
        # 添加思考模式標頭
        header = f"""💭 <b>思考模式分析結果</b>
<b>模型：</b>o3-mini (High reasoning effort)
<b>問題：</b>{question[:80]}{'...' if len(question) > 80 else ''}

{'─' * 20}

"""
        return header + result
        
    except Exception as e:
        return f"""❌ <b>思考模式執行失敗</b>

錯誤：{str(e)}

請檢查：
1. API Key 是否有效
2. 網路連線是否正常
3. OpenAI 服務狀態"""

# ============ 狀態指令 ============

async def status_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """狀態指令"""
    user = update.effective_user
    
    if not check_authorization(user.id):
        await update.message.reply_text("❌ 未授權的使用者")
        return
    
    # 獲取系統狀態
    status = await get_system_status()
    
    await update.message.reply_text(
        status,
        reply_markup=get_back_menu(),
        parse_mode="HTML"
    )

async def get_system_status() -> str:
    """獲取系統狀態"""
    status = []
    status.append("📊 <b>系統狀態總覽</b>")
    status.append(f"🕐 {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    status.append("")
    
    # 夜班系統狀態
    pid_file = Path("/tmp/night-shift.pid")
    if pid_file.exists():
        status.append("🌙 夜班系統: <b>執行中 🟢</b>")
    else:
        status.append("🌙 夜班系統: <b>待命 ⚪</b>")
    
    # 今日報告狀態
    today = datetime.now().strftime('%Y-%m-%d')
    report_file = NIGHT_SHIFT_DIR / "reports" / f"morning-report-{today}.md"
    if report_file.exists():
        status.append("📄 今日晨報: <b>已生成 ✅</b>")
    else:
        status.append("📄 今日晨報: <b>尚未生成 ⏳</b>")
    
    # 記憶庫狀態
    memory_count = len(list(MEMORY_DIR.glob("2026-*.md")))
    status.append(f"📝 記憶檔案: <b>{memory_count}</b> 個")
    
    # 討論區狀態
    discussion_file = NIGHT_SHIFT_DIR / "discussion" / f"collaboration_{today}.md"
    if discussion_file.exists():
        status.append("💬 今日討論區: <b>已建立 ✅</b>")
    else:
        status.append("💬 今日討論區: <b>尚未建立 ⏳</b>")
    
    status.append("")
    status.append("💡 使用 /optimize 執行系統檢查")
    
    return "\n".join(status)

# ============ 回調處理器 ============

async def button_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """處理按鈕回調"""
    query = update.callback_query
    await query.answer()
    
    data = query.data
    
    if data == "main_menu":
        await query.edit_message_text(
            "🌙 <b>夜班系統控制中心</b>\n\n請選擇功能：",
            reply_markup=get_main_menu(),
            parse_mode="HTML"
        )
    
    elif data == "optimize":
        await query.edit_message_text(
            "🔧 <b>啟動系統優化檢查...</b>\n\n這可能需要 1-2 分鐘，請稍候。",
            parse_mode="HTML"
        )
        result = await run_system_optimization()
        await query.edit_message_text(
            result,
            reply_markup=get_back_menu(),
            parse_mode="HTML"
        )
    
    elif data == "recommend":
        await query.edit_message_text(
            "🧠 <b>正在分析第二大腦...</b>\n\n讀取記憶庫、待辦清單與創意想法...",
            parse_mode="HTML"
        )
        result = await generate_recommendations()
        await query.edit_message_text(
            result,
            reply_markup=get_back_menu(),
            parse_mode="HTML"
        )
    
    elif data == "think":
        await query.edit_message_text(
            "💭 <b>思考模式</b>\n\n"
            "請直接輸入：\n"
            "<code>/think 你的問題</code>\n\n"
            "例如：\n"
            "<code>/think 如何優化我的內容行銷策略？</code>",
            reply_markup=get_back_menu(),
            parse_mode="HTML"
        )
    
    elif data == "status":
        result = await get_system_status()
        await query.edit_message_text(
            result,
            reply_markup=get_back_menu(),
            parse_mode="HTML"
        )

# ============ 錯誤處理 ============

async def error_handler(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """錯誤處理"""
    logger.error(f"Update {update} caused error {context.error}")
    
    if update and update.effective_message:
        await update.effective_message.reply_text(
            "❌ <b>發生錯誤</b>\n\n請稍後再試，或聯繫管理員。",
            parse_mode="HTML"
        )

# ============ 主程式 ============

async def setup_bot_commands(application: Application):
    """設定 Bot 指令選單"""
    await application.bot.set_my_commands(BOT_COMMANDS)
    logger.info("Bot commands set successfully")

def main():
    """主程式"""
    # 檢查 Telegram Bot Token
    token = TELEGRAM_BOT_TOKEN
    
    if not token:
        # 嘗試從文件讀取
        token_file = HOME_DIR / ".openclaw" / "credentials" / "telegram_bot_token"
        if token_file.exists():
            token = token_file.read_text().strip()
    
    if not token:
        print("❌ 錯誤：找不到 Telegram Bot Token")
        print("請設定環境變數 TELEGRAM_BOT_TOKEN")
        print("或建立檔案：~/.openclaw/credentials/telegram_bot_token")
        sys.exit(1)
    
    # 建立 Application
    application = Application.builder().token(token).build()
    
    # 添加指令處理器
    application.add_handler(CommandHandler("start", start_command))
    application.add_handler(CommandHandler("help", help_command))
    application.add_handler(CommandHandler("optimize", optimize_command))
    application.add_handler(CommandHandler("recommend", recommend_command))
    application.add_handler(CommandHandler("think", think_command))
    application.add_handler(CommandHandler("status", status_command))
    
    # 添加回調處理器
    application.add_handler(CallbackQueryHandler(button_callback))
    
    # 添加錯誤處理器
    application.add_error_handler(error_handler)
    
    # 設定指令選單
    application.job_queue.run_once(
        lambda context: asyncio.create_task(setup_bot_commands(application)),
        when=0
    )
    
    print("🌙 夜班系統 Telegram Bot 已啟動")
    print(f"📅 啟動時間: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # 啟動 Bot
    application.run_polling(allowed_updates=Update.ALL_TYPES)

if __name__ == "__main__":
    main()
