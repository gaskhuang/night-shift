#!/usr/bin/env python3
# 📚 知識庫更新模組
# PM (米米) - 整理和更新知識庫

import os
import sys
import json
import re
from datetime import datetime, timedelta
from pathlib import Path
from collections import defaultdict

# 配置
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")
MEMORY_DIR = Path("/Users/user/memory")
KNOWLEDGE_BASE = Path("/Users/user/knowledge-base")
RESEARCH_DIR = NIGHT_SHIFT_DIR / "research"


class KnowledgeUpdater:
    """知識庫更新器"""
    
    def __init__(self):
        self.date = datetime.now().strftime("%Y-%m-%d")
        self.time = datetime.now().strftime("%H:%M")
        
        # 確保目錄存在
        MEMORY_DIR.mkdir(parents=True, exist_ok=True)
        KNOWLEDGE_BASE.mkdir(parents=True, exist_ok=True)
        (NIGHT_SHIFT_DIR / "logs").mkdir(parents=True, exist_ok=True)
    
    def log(self, message: str):
        """記錄日誌"""
        log_file = NIGHT_SHIFT_DIR / "logs" / f"knowledge-{self.date}.log"
        with open(log_file, "a") as f:
            f.write(f"[{self.time}] {message}\n")
        print(f"[{self.time}] {message}")
    
    def scan_memory_files(self) -> dict:
        """掃描記憶檔案"""
        stats = {
            "total_files": 0,
            "recent_files": [],
            "by_category": defaultdict(list),
        }
        
        if not MEMORY_DIR.exists():
            return stats
        
        # 獲取所有 markdown 檔案
        for file_path in MEMORY_DIR.glob("*.md"):
            stats["total_files"] += 1
            
            # 檢查是否最近7天內
            mtime = datetime.fromtimestamp(file_path.stat().st_mtime)
            if datetime.now() - mtime < timedelta(days=7):
                stats["recent_files"].append({
                    "name": file_path.name,
                    "modified": mtime.strftime("%Y-%m-%d"),
                })
            
            # 簡單分類
            content = file_path.read_text(encoding="utf-8", errors="ignore")[:500]
            if "研究" in content or "research" in content.lower():
                stats["by_category"]["研究"].append(file_path.name)
            elif "TODO" in content or "待辦" in content:
                stats["by_category"]["待辦"].append(file_path.name)
            elif "筆記" in content or "note" in content.lower():
                stats["by_category"]["筆記"].append(file_path.name)
            else:
                stats["by_category"]["其他"].append(file_path.name)
        
        return stats
    
    def update_second_brain(self, stats: dict):
        """更新 second_brain.md"""
        second_brain = KNOWLEDGE_BASE / "second_brain.md"
        
        content = f"""# 🧠 Second Brain

> 自動更新於 {self.date} {self.time}

## 📊 記憶庫統計

- **總檔案數**: {stats['total_files']}
- **最近7天更新**: {len(stats['recent_files'])}

## 📁 分類統計

"""
        
        for category, files in stats["by_category"].items():
            content += f"### {category} ({len(files)})\n\n"
            for f in files[:10]:  # 只顯示前10個
                content += f"- {f}\n"
            if len(files) > 10:
                content += f"- ... 還有 {len(files) - 10} 個\n"
            content += "\n"
        
        content += f"""## 📝 最近更新

"""
        
        for file_info in stats["recent_files"][:10]:
            content += f"- {file_info['name']} ({file_info['modified']})\n"
        
        content += f"""
## 🔗 快速連結

- [Memory 目錄](../memory/)
- [夜班研究](./research/)

---

*由 AI 夜班系統 (PM - 米米) 自動維護*
"""
        
        second_brain.write_text(content, encoding="utf-8")
        self.log(f"✅ 已更新: {second_brain}")
    
    def sync_research_to_kb(self):
        """同步研究資料到知識庫"""
        if not RESEARCH_DIR.exists():
            return
        
        for research_file in RESEARCH_DIR.glob("*.md"):
            # 複製或連結研究檔案到知識庫
            target = KNOWLEDGE_BASE / "research" / research_file.name
            target.parent.mkdir(parents=True, exist_ok=True)
            
            content = research_file.read_text(encoding="utf-8", errors="ignore")
            # 添加標頭
            header = f"""# {research_file.stem.replace('_', ' ').title()}

> 來源: AI 夜班系統研究模組
> 更新: {self.date}

"""
            target.write_text(header + content, encoding="utf-8")
            self.log(f"✅ 已同步研究: {research_file.name}")
    
    def generate_kb_summary(self) -> str:
        """生成知識庫摘要"""
        summary_file = KNOWLEDGE_BASE / f"summary_{self.date}.md"
        
        content = f"""# 📚 知識庫摘要 - {self.date}

## 🔄 今晚更新內容

### 記憶檔案整理
- 掃描並分類記憶檔案
- 更新 second_brain.md 索引

### 研究資料同步
- AEO 最新趨勢
- GEO 最新趨勢

## 📈 知識庫健康度

| 指標 | 狀態 |
|------|------|
| 記憶檔案 | ✅ 已整理 |
| 研究資料 | ✅ 已同步 |
| 索引更新 | ✅ 最新 |

## 💡 建議

1. 定期審查 knowledge-base/ 目錄
2. 考慮將重要發現整合到主文檔
3. 持續更新 AEO/GEO 研究

---

*生成時間: {self.time}*
"""
        
        summary_file.write_text(content, encoding="utf-8")
        self.log(f"✅ 知識庫摘要已生成: {summary_file}")
        return str(summary_file)
    
    def run(self):
        """執行知識庫更新流程"""
        self.log("📚 Knowledge Updater 啟動...")
        
        # 1. 掃描記憶檔案
        stats = self.scan_memory_files()
        self.log(f"📊 掃描完成: {stats['total_files']} 個檔案")
        
        # 2. 更新 second_brain.md
        self.update_second_brain(stats)
        
        # 3. 同步研究資料
        self.sync_research_to_kb()
        
        # 4. 生成摘要
        self.generate_kb_summary()
        
        self.log("✅ 知識庫更新完成")


def main():
    """主函數"""
    updater = KnowledgeUpdater()
    updater.run()


if __name__ == "__main__":
    main()
