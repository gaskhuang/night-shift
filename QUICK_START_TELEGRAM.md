# 📱 Telegram Bot 快速入門

> 透過 Telegram 隨時隨地控制夜班系統

## 🚀 快速啟動

```bash
# 一鍵啟動整個系統
/Users/user/night-shift/start_system.sh

# 或分步啟動
/Users/user/night-shift/start_telegram_bot.sh
python3 /Users/user/night-shift/setup_bot_menu.py
```

## 📋 指令列表

### 主要指令

| 指令 | 功能 | 說明 |
|------|------|------|
| `/start` | 啟動機器人 | 顯示主選單 |
| `/optimize` | 🔧 系統優化 | 執行夜班系統檢查 |
| `/recommend` | 🧠 第二大腦推薦 | 分析並推薦下一步行動 |
| `/think` | 💭 思考模式 | GPT-5.4 深度推理分析 |
| `/status` | 📊 查看狀態 | 查看系統狀態 |
| `/help` | 顯示說明 | 顯示使用說明 |

### 思考模式用法

```
/think 如何優化我的內容行銷策略？
/think 分析這個商業模式的風險點
/think 幫我拆解這個複雜問題
/think 制定下季度的成長策略
```

**適用場景：**
- 複雜問題的拆解與分析
- 需要多步驟邏輯推演的研究
- 策略規劃與決策建議

## 🎛️ 主選單按鈕

點擊 `/start` 後會顯示主選單：

- 🔧 **系統優化** - 每天晚上都要做的系統檢查
- 🧠 **第二大腦推薦** - 從第二大腦分析，推薦下一步要做什麼
- 💭 **思考模式** - GPT-5.4 深度推理分析複雜問題
- 📊 **查看狀態** - 查看系統狀態

## 📱 使用流程

### 每天早上

1. **08:30** - 自動收到「今日行動推薦」
2. 查看推薦的「下一步要做什麼」
3. 根據能量狀態選擇行動

### 需要分析時

1. 輸入 `/think 你的問題`
2. 等待 GPT-5.4 深度推理（約 30-60 秒）
3. 查看結構化的分析結果

### 檢查系統

1. 點擊 🔧 **系統優化**
2. 查看磁碟、記憶體、服務狀態
3. 執行清理任務

## 🔧 管理指令

```bash
# 查看 Bot 狀態
/Users/user/night-shift/status_telegram_bot.sh

# 停止 Bot
/Users/user/night-shift/stop_telegram_bot.sh

# 重新啟動
/Users/user/night-shift/stop_telegram_bot.sh
/Users/user/night-shift/start_telegram_bot.sh

# 更新選單
python3 /Users/user/night-shift/setup_bot_menu.py
```

## ⚙️ 設定

### 環境變數

```bash
# 設定 Bot Token
export TELEGRAM_BOT_TOKEN="your_bot_token_here"

# 設定允許的使用者 (可選)
export TELEGRAM_ALLOWED_USER_ID="your_telegram_user_id"
```

### 或建立設定檔

```bash
# 建立 credentials 目錄
mkdir -p ~/.openclaw/credentials

# 儲存 Bot Token
echo "your_bot_token_here" > ~/.openclaw/credentials/telegram_bot_token

# 儲存 OpenAI API Key (用於思考模式)
echo "your_openai_key_here" > ~/.openclaw/credentials/openai.key
```

## 📝 功能詳情

### 🔧 系統優化

執行內容：
- 檢查夜班系統狀態
- 檢查磁碟空間
- 檢查記憶檔案數量
- 檢查最近日誌
- 清理暫存檔案

### 🧠 第二大腦推薦

分析來源：
- TASK_LIST.md (待辦任務)
- memory/*.md (近期記憶)
- IDEA.md (進行中的創意)
- 系統狀態數據

推薦內容：
- 優先處理的事項
- 待完成的任務
- 創意發想建議
- 下一步行動

### 💭 思考模式

模型：GPT-5.4 (OpenAI o3-mini)

輸出格式：
- 問題的核心拆解
- 多角度的分析框架
- 具體的行動建議
- 潛在風險與注意事項

## ❓ 常見問題

**Q: Bot 沒有回應？**  
A: 檢查 Bot 是否在執行：`/Users/user/night-shift/status_telegram_bot.sh`

**Q: 思考模式顯示 API Key 錯誤？**  
A: 設定 OpenAI API Key：`echo "sk-..." > ~/.openclaw/credentials/openai.key`

**Q: 如何修改選單？**  
A: 編輯 `setup_bot_menu.py` 中的 `BOT_COMMANDS` 列表，然後重新執行設定

**Q: 推薦什麼時候生成？**  
A: 每天早上 08:30 自動生成，也可手動執行 `/recommend`

## 📚 相關文件

- [夜班系統 v2.5](./NIGHT_SHIFT_SYSTEM_v2.md)
- [Telegram Bot 完整說明](./TELEGRAM_BOT_README.md)
- [快速入門](./QUICK_START.md)

---

*最後更新: 2026-03-07*
