#!/bin/bash
# 🔧 設定夜班系統 v2.0 的 cron 排程
# 每20分鐘一個任務，08:30 生成行動推薦

echo "🌙 設定夜班系統 v2.0 Cron 排程..."
echo ""

# 先備份現有 crontab
crontab -l > /tmp/crontab_backup_$(date +%Y%m%d_%H%M%S).txt 2>/dev/null || echo "無現有 crontab"

# 建立新的 crontab 內容
cat > /tmp/night_shift_v2_cron.txt << 'EOF'
# 🌙 AI 夜班系統 v2.0 - 每20分鐘一個任務
# 夜班時間: 23:00 - 06:30

# 夜班任務 (每20分鐘執行一次)
0,20,40 23 * * * /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1
0,20,40 0,1,2,3,4,5 * * * /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1
0 6 * * * /Users/user/night-shift/orchestrator_v2.sh >> /Users/user/night-shift/logs/cron.log 2>&1

# 🎯 每天早上 08:30 生成今日行動推薦
30 8 * * * /Users/user/night-shift/daily-iteration/next_action_engine.sh >> /Users/user/night-shift/logs/cron.log 2>&1

# 📝 每天晚上 22:00 提醒覆盤 (可選)
# 0 22 * * * echo "🌆 記得做每日覆盤！" >> /Users/user/night-shift/logs/reminder.log 2>&1
EOF

echo "📋 將要安裝的 cron 設定:"
echo "========================================"
cat /tmp/night_shift_v2_cron.txt
echo "========================================"
echo ""

# 合併現有 crontab（保留非夜班相關的設定）
echo "🔄 安裝中..."
(
    # 保留現有 crontab 中不含 night-shift 的行
    crontab -l 2>/dev/null | grep -v "night-shift" | grep -v "NIGHT" || true
    echo ""
    cat /tmp/night_shift_v2_cron.txt
) | crontab -

echo "✅ Cron 設定完成！"
echo ""
echo "📊 目前的 crontab:"
crontab -l | tail -20
echo ""
echo "💡 提示:"
echo "  - 夜班任務將在 23:00 - 06:00 每20分鐘執行"
echo "  - 行動推薦將在每天 08:30 生成"
echo "  - 日誌位置: night-shift/logs/cron.log"
