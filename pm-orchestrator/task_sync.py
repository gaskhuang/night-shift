#!/usr/bin/env python3
# 📋 Google Tasks 同步模組
# 抓取 Google Tasks 待辦清單並整合到 TASK_LIST.md

import os
import json
from datetime import datetime
from pathlib import Path

# 配置
TASK_LIST_PATH = Path("/Users/user/memory/TASK_LIST.md")
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")


class GoogleTasksSync:
    """Google Tasks 同步器"""
    
    def __init__(self):
        self.date = datetime.now().strftime("%Y-%m-%d")
        self.time = datetime.now().strftime("%H:%M")
        
    def log(self, message: str):
        """記錄日誌"""
        log_file = NIGHT_SHIFT_DIR / "logs" / f"task-sync-{self.date}.log"
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(log_file, "a") as f:
            f.write(f"[{self.time}] {message}\n")
        print(f"[{self.time}] {message}")
    
    def fetch_google_tasks(self) -> list:
        """
        從 Google Tasks API 抓取待辦清單
        
        TODO: 實作 Google Tasks API 整合
        需要:
        1. Google OAuth2 認證
        2. Tasks API 存取權限
        3. 定期刷新 token
        """
        # 這是占位符，實際實作需要 Google API
        self.log("📝 正在抓取 Google Tasks...")
        
        # 模擬回傳資料
        return [
            {"title": "待辦事項 1", "priority": "P0", "due": "2026-03-08"},
            {"title": "待辦事項 2", "priority": "P1", "due": "2026-03-09"},
        ]
    
    def update_task_list_md(self, tasks: list):
        """更新 TASK_LIST.md"""
        self.log(f"📝 更新 TASK_LIST.md，新增 {len(tasks)} 個任務")
        
        # 讀取現有內容
        existing_content = ""
        if TASK_LIST_PATH.exists():
            existing_content = TASK_LIST_PATH.read_text(encoding="utf-8")
        
        # 建立新內容
        new_section = f"\n\n## 夜班同步任務 ({self.date} {self.time})\n\n"
        
        # 按優先級分類
        p0_tasks = [t for t in tasks if t.get("priority") == "P0"]
        p1_tasks = [t for t in tasks if t.get("priority") == "P1"]
        p2_tasks = [t for t in tasks if t.get("priority") not in ["P0", "P1"]]
        
        if p0_tasks:
            new_section += "### 🔴 P0 高優先\n"
            for task in p0_tasks:
                new_section += f"- [ ] {task['title']} (期限: {task.get('due', '未設定')})\n"
            new_section += "\n"
        
        if p1_tasks:
            new_section += "### 🟡 P1 中優先\n"
            for task in p1_tasks:
                new_section += f"- [ ] {task['title']} (期限: {task.get('due', '未設定')})\n"
            new_section += "\n"
        
        if p2_tasks:
            new_section += "### 🟢 P2 低優先\n"
            for task in p2_tasks:
                new_section += f"- [ ] {task['title']} (期限: {task.get('due', '未設定')})\n"
            new_section += "\n"
        
        # 寫入檔案
        updated_content = existing_content + new_section
        TASK_LIST_PATH.write_text(updated_content, encoding="utf-8")
        
        self.log(f"✅ TASK_LIST.md 已更新")
    
    def sync(self):
        """執行完整同步"""
        self.log("🚀 開始 Google Tasks 同步")
        
        try:
            tasks = self.fetch_google_tasks()
            self.update_task_list_md(tasks)
            self.log("✅ 同步完成")
            return True
        except Exception as e:
            self.log(f"❌ 同步失敗: {e}")
            return False


def main():
    """主函數"""
    syncer = GoogleTasksSync()
    syncer.sync()


if __name__ == "__main__":
    main()
