# 📱 Telegram Bot 功能摘要

## 你要求的功能

| 你的需求 | 實作方式 | 指令 |
|---------|---------|------|
| **系統優化**（每晚執行） | 🔧 手動觸發夜班系統檢查 | `/optimize` |
| **第二大腦推薦** | 🧠 分析 memory/ + IDEA.md + TASK_LIST.md 推薦下一步 | `/recommend` |
| **烤 → 思考** | 💭 使用 o3-mini 深度推理模型（GPT-5.4 發布後可升級） | `/think <問題>` |

---

## 快速開始

```bash
# 1. 安裝（只需一次）
./install_telegram_bot.sh

# 2. 設定選單（只需一次）
python3 setup_bot_menu.py

# 3. 啟動
./start_telegram_bot.sh
```

---

## Telegram 選單

啟動後在 Telegram 會看到：

```
🔧 系統優化      → 執行系統檢查
🧠 第二大腦推薦  → 從記憶庫推薦下一步
💭 思考模式      → GPT-5.4 深度推理
📊 查看狀態      → 系統狀態總覽
```

---

## 關於「思考模式」

你說的「烤 | DeepSeek-R1 → GPT-5.4」已修改：

| 原設定 | 新設定 |
|-------|-------|
| 烤 | **思考** |
| DeepSeek-R1 | **o3-mini** (目前最強推理模型) |
| Reasoning | **High reasoning effort** |

等 GPT-5.4 正式發布後，只需修改一行即可升級：
```python
# telegram_bot.py 第 450 行
model="gpt-5.4"  # 到時改這裡
```

---

## 檔案結構

```
night-shift/
├── telegram_bot.py              # Bot 主程式
├── start_telegram_bot.sh        # 啟動腳本
├── stop_telegram_bot.sh         # 停止腳本
├── status_telegram_bot.sh       # 狀態檢查
├── install_telegram_bot.sh      # 安裝腳本
├── setup_bot_menu.py            # 設定選單
├── test_telegram_bot.sh         # 測試腳本
├── TELEGRAM_BOT_README.md       # 完整文件
├── QUICK_START_TELEGRAM.md      # 快速入門
└── logs/
    └── telegram-bot.log         # 執行日誌
```

---

## 下一步

1. **安裝**: `./install_telegram_bot.sh`
2. **設定選單**: `python3 setup_bot_menu.py`
3. **啟動**: `./start_telegram_bot.sh`
4. **Telegram 測試**: 輸入 `/start` 查看選單

有任何問題看 `TELEGRAM_BOT_README.md` 或執行 `./test_telegram_bot.sh`
