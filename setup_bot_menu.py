#!/usr/bin/env python3
"""
🤖 Telegram Bot Menu 設定腳本
用於手動設定或更新 Bot 的指令選單
"""

import os
import sys
import asyncio
from pathlib import Path
from telegram import Bot, BotCommand

# Bot 指令選單設定
BOT_COMMANDS = [
    BotCommand("start", "啟動機器人並顯示主選單"),
    BotCommand("optimize", "🔧 系統優化 - 執行夜班系統檢查"),
    BotCommand("recommend", "🧠 第二大腦推薦 - 分析並推薦下一步行動"),
    BotCommand("think", "💭 思考模式 - GPT-5.4 深度推理分析"),
    BotCommand("status", "📊 查看系統狀態"),
    BotCommand("help", "顯示使用說明"),
]

async def setup_menu(bot_token: str):
    """設定 Bot 指令選單"""
    bot = Bot(token=bot_token)
    
    try:
        # 設定指令選單
        await bot.set_my_commands(BOT_COMMANDS)
        print("✅ Bot 指令選單已設定成功！")
        
        # 顯示設定的指令
        print("\n📋 已設定的指令：")
        print("─" * 50)
        for cmd in BOT_COMMANDS:
            print(f"  /{cmd.command:<12} - {cmd.description}")
        print("─" * 50)
        
        # 取得 Bot 資訊
        me = await bot.get_me()
        print(f"\n🤖 Bot 資訊：")
        print(f"   名稱: {me.first_name}")
        print(f"   使用者名稱: @{me.username}")
        print(f"   ID: {me.id}")
        
    except Exception as e:
        print(f"❌ 設定失敗: {e}")
        return False
    
    return True

def main():
    """主程式"""
    print("🤖 Telegram Bot Menu 設定工具")
    print("=" * 50)
    
    # 取得 Bot Token
    token = os.getenv("TELEGRAM_BOT_TOKEN", "")
    
    if not token:
        # 嘗試從檔案讀取
        token_file = Path.home() / ".openclaw" / "credentials" / "telegram_bot_token"
        if token_file.exists():
            token = token_file.read_text().strip()
    
    if not token:
        print("❌ 錯誤：找不到 Telegram Bot Token")
        print("請設定環境變數 TELEGRAM_BOT_TOKEN")
        print("或建立檔案：~/.openclaw/credentials/telegram_bot_token")
        sys.exit(1)
    
    # 執行設定
    result = asyncio.run(setup_menu(token))
    
    if result:
        print("\n✅ 設定完成！")
        print("\n現在在 Telegram 中：")
        print("1. 打開與 Bot 的對話")
        print("2. 點擊輸入框左側的 / 按鈕")
        print("3. 即可看到所有指令選單")
    else:
        print("\n❌ 設定失敗，請檢查 Token 是否正確")
        sys.exit(1)

if __name__ == "__main__":
    main()
