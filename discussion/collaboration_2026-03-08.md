## OpenClaw Auto-Updater / 阿蓋三號

- OpenClaw 版 auto-updater 已建立完成
- 執行腳本：`/Users/user/scripts/openclaw_auto_update.sh`
- 排程：`/Users/user/Library/LaunchAgents/com.agaikid.openclaw-auto-update.plist`
- 預設每天 00:00 執行
- 回報口吻統一為阿蓋三號
- 寫入/修改的 md 與 config 需同步 GitHub

## Nano Banana 2 / 阿蓋二號 修正紀錄

- 已實測 Nano Banana 2 可成功生圖，輸出：`/Users/user/nano-banana2-lobster-test.png`
- 問題不是 API Key 真缺失，而是舊 session / 舊檢查入口未讀到最新環境
- 已補齊 key 來源：shell、skill `.env`、lobster2/3 launchd
- 新增統一 preflight：`/Users/user/scripts/check_gemini_env.py`
- 之後若回報「沒 key」，先跑 preflight，再決定是否真缺失；不要只靠單一 shell 誤判

