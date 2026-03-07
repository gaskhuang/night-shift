# 🌙 夜班系統 Telegram Bot

透過 Telegram 輕鬆控制您的 AI 夜班系統，整合第二大腦推薦與 GPT-5.4 深度思考功能。

## 📋 功能選單

| 指令 | 功能 | 說明 |
|------|------|------|
| `/start` | 主選單 | 顯示所有功能選項 |
| `/optimize` | 🔧 系統優化 | 手動執行系統檢查與優化 |
| `/recommend` | 🧠 第二大腦推薦 | 分析記憶庫並推薦下一步行動 |
| `/think` | 💭 思考模式 | GPT-5.4 深度推理分析 |
| `/status` | 📊 系統狀態 | 查看夜班系統狀態 |
| `/help` | 說明 | 顯示使用說明 |

## 🚀 快速開始

### 1. 安裝

```bash
cd ~/night-shift
./install_telegram_bot.sh
```

安裝腳本會：
- 創建 Python 虛擬環境
- 安裝 python-telegram-bot 和 openai
- 設定 Telegram Bot Token
- 設定 OpenAI API Key
- 建立快捷指令

### 2. 取得 Telegram Bot Token

1. 在 Telegram 搜尋 `@BotFather`
2. 發送 `/newbot` 指令
3. 依指示設定 Bot 名稱和使用者名稱
4. 取得 Token (格式: `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)

### 3. 啟動 Bot

```bash
./start_telegram_bot.sh
```

或重開終端後使用快捷指令：
```bash
ns-bot-start
```

## 📱 使用方式

### 🔧 系統優化

手動觸發夜班系統的檢查流程：
- 檢查夜班系統狀態
- 檢查磁碟空間
- 統計記憶檔案數量
- 清理暫存檔案
- 檢查日誌狀態

**使用方式**：
- Telegram 輸入 `/optimize`
- 或點選選單中的「🔧 系統優化」

### 🧠 第二大腦推薦

分析您的個人知識庫：
- 讀取 `memory/TASK_LIST.md` 的待辦任務
- 分析最近幾天的記憶檔案
- 讀取 `IDEA.md` 的執行中創意
- 智能推薦下一步行動

**使用方式**：
- Telegram 輸入 `/recommend`
- 或點選選單中的「🧠 第二大腦推薦」

### 💭 思考模式 (GPT-5.4)

使用 GPT-o3-mini (作為 GPT-5.4 的替代) 進行深度推理：
- 複雜問題拆解
- 多角度分析框架
- 具體行動建議
- 風險評估

**使用方式**：
```
/think 如何優化我的內容行銷策略？
```

**適用場景**：
- 複雜問題的拆解與分析
- 需要多步驟邏輯推演的研究
- 策略規劃與決策建議

## 🔒 安全性

- Bot Token 和 API Key 儲存在 `~/.openclaw/credentials/`，權限設為 600
- 預設只允許特定 Telegram User ID 使用（可在安裝時設定）
- 支援環境變數設定：`TELEGRAM_BOT_TOKEN`、`OPENAI_API_KEY`

## 📝 快捷指令

安裝後可使用以下快捷指令：

| 指令 | 功能 |
|------|------|
| `ns-bot-start` | 啟動 Bot |
| `ns-bot-stop` | 停止 Bot |
| `ns-bot-status` | 查看狀態 |
| `ns-bot-log` | 查看即時日誌 |

## 🐛 故障排除

### Bot 無法啟動

1. 檢查 Token 是否正確：
   ```bash
   cat ~/.openclaw/credentials/telegram_bot_token
   ```

2. 檢查日誌：
   ```bash
   tail -f ~/night-shift/logs/telegram-bot.log
   ```

3. 確認沒有其他 Bot 實例在執行：
   ```bash
   pgrep -f telegram_bot.py
   ```

### 思考模式無法使用

1. 檢查 OpenAI API Key：
   ```bash
   cat ~/.openclaw/credentials/openai.key
   ```

2. 確認 API Key 有效且有足夠額度

### 修改設定

直接編輯憑證檔案：
```bash
# 修改 Token
echo "新Token" > ~/.openclaw/credentials/telegram_bot_token

# 修改 API Key
echo "新APIKey" > ~/.openclaw/credentials/openai.key

# 修改允許的使用者 ID
echo "新UserID" > ~/.openclaw/credentials/telegram_allowed_user_id
```

## 🔄 更新 Bot

重新執行安裝腳本即可更新：
```bash
./install_telegram_bot.sh
```

## 📊 系統整合

此 Bot 與以下系統整合：
- 🌙 夜班系統 (`night-shift/`)
- 🧠 第二大腦 (`memory/`、`IDEA.md`)
- 🤖 OpenAI API（思考模式）

## 💡 使用建議

1. **每天早上**：使用 `/recommend` 查看今日建議
2. **發現問題**：使用 `/optimize` 執行系統檢查
3. **需要決策**：使用 `/think [問題]` 進行深度分析
4. **定期查看**：使用 `/status` 確認系統狀態

---

🦞 Powered by OpenClaw Night Shift System
