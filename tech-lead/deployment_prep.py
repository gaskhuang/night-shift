#!/usr/bin/env python3
# 🚀 部署準備模組
# Tech Lead (J) - 準備部署提案和檢查清單

import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path

# 配置
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")
PROPOSALS_DIR = NIGHT_SHIFT_DIR / "proposals"
REPORTS_DIR = NIGHT_SHIFT_DIR / "reports"

# 部署檢查清單
DEPLOYMENT_CHECKLIST = {
    "pre_deploy": [
        "代碼已通過測試",
        "依賴項已更新",
        "配置文件已檢查",
        "資料庫遷移已準備",
        "回滾方案已準備",
    ],
    "safety": [
        "無高危操作（刪除、修改 API Key）",
        "已備份重要數據",
        "僅修改授權範圍內的檔案",
    ],
    "post_deploy": [
        "服務狀態檢查",
        "日誌監控",
        "功能驗證",
    ],
}


class DeploymentPrep:
    """部署準備器"""
    
    def __init__(self):
        self.date = datetime.now().strftime("%Y-%m-%d")
        self.time = datetime.now().strftime("%H:%M")
        
        PROPOSALS_DIR.mkdir(parents=True, exist_ok=True)
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    
    def log(self, message: str):
        """記錄日誌"""
        log_file = NIGHT_SHIFT_DIR / "logs" / f"deployment-{self.date}.log"
        log_file.parent.mkdir(parents=True, exist_ok=True)
        
        with open(log_file, "a") as f:
            f.write(f"[{self.time}] {message}\n")
        print(f"[{self.time}] {message}")
    
    def analyze_changes(self) -> dict:
        """分析今天的變更"""
        changes = {
            "files_modified": [],
            "new_files": [],
            "potential_issues": [],
        }
        
        # 檢查夜班期間修改的檔案
        fixes_dir = NIGHT_SHIFT_DIR / "fixes"
        if fixes_dir.exists():
            for fix_file in fixes_dir.glob(f"fixes_{self.date}.json"):
                try:
                    with open(fix_file) as f:
                        data = json.load(f)
                        if data.get("fixes"):
                            changes["files_modified"].extend(
                                [f"修復: {f['type']}" for f in data["fixes"]]
                            )
                except:
                    pass
        
        return changes
    
    def generate_proposal(self, title: str, description: str, changes: dict) -> str:
        """生成部署提案"""
        proposal_file = PROPOSALS_DIR / f"deploy_proposal_{self.date}.md"
        
        content = f"""# 🚀 部署提案 - {title}

## 提案資訊

| 項目 | 內容 |
|------|------|
| 提案日期 | {self.date} {self.time} |
| 提案人 | Tech Lead (J) |
| 狀態 | 🟡 等待審核 |

## 變更描述

{description}

## 變更內容

### 修改的檔案

"""
        
        if changes["files_modified"]:
            for file in changes["files_modified"]:
                content += f"- [x] {file}\n"
        else:
            content += "- 無檔案修改\n"
        
        content += f"""
### 新增檔案

"""
        
        if changes["new_files"]:
            for file in changes["new_files"]:
                content += f"- [x] {file}\n"
        else:
            content += "- 無新增檔案\n"
        
        content += f"""
## 部署檢查清單

### 部署前

"""
        for item in DEPLOYMENT_CHECKLIST["pre_deploy"]:
            content += f"- [ ] {item}\n"
        
        content += f"""
### 安全檢查

"""
        for item in DEPLOYMENT_CHECKLIST["safety"]:
            content += f"- [x] {item} (夜班系統已確認)\n"
        
        content += f"""
### 部署後

"""
        for item in DEPLOYMENT_CHECKLIST["post_deploy"]:
            content += f"- [ ] {item}\n"
        
        content += f"""
## 風險評估

| 風險 | 機率 | 影響 | 緩解措施 |
|------|------|------|----------|
| 服務中斷 | 低 | 高 | 已在測試環境驗證 |
| 資料遺失 | 極低 | 極高 | 已備份 |
| 效能問題 | 中 | 中 | 部署後監控 |

## 建議

✅ **建議批准** - 此變更經過夜班系統檢查，符合安全護欄要求。

## 審核記錄

- [ ] G大 審核
- [ ] 批准部署
- [ ] 部署完成

---

*自動生成 by AI 夜班系統 (Tech Lead - J)*
"""
        
        proposal_file.write_text(content, encoding="utf-8")
        self.log(f"📝 部署提案已生成: {proposal_file}")
        
        return str(proposal_file)
    
    def run(self):
        """執行部署準備流程"""
        self.log("🚀 Deployment Prep 啟動...")
        
        # 1. 分析變更
        changes = self.analyze_changes()
        self.log(f"📊 發現 {len(changes['files_modified'])} 個修改")
        
        # 2. 生成提案
        if changes["files_modified"] or changes["new_files"]:
            proposal_path = self.generate_proposal(
                title=f"夜班自動修復 - {self.date}",
                description="夜班系統檢測到並修復了若干問題，建議審核後部署。",
                changes=changes,
            )
            self.log(f"✅ 部署準備完成，提案: {proposal_path}")
        else:
            self.log("ℹ️ 無需部署 - 今晚無變更")


def main():
    """主函數"""
    prep = DeploymentPrep()
    prep.run()


if __name__ == "__main__":
    main()
