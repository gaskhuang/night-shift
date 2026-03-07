#!/usr/bin/env python3
# 🔧 Bug 修復模組
# Tech Lead (J) 的核心工具 - 自動識別並修復小問題

import os
import sys
import re
import json
import subprocess
from datetime import datetime
from pathlib import Path

# 配置
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")
LOG_DIR = NIGHT_SHIFT_DIR / "logs"
FIXES_DIR = NIGHT_SHIFT_DIR / "fixes"

# 常見問題模式與修復
COMMON_ISSUES = {
    "python_syntax": {
        "pattern": r"SyntaxError.*",
        "description": "Python 語法錯誤",
        "auto_fixable": False,
    },
    "missing_import": {
        "pattern": r"ImportError: No module named '(\w+)'",
        "description": "缺失 Python 模組",
        "auto_fixable": True,
        "fix_command": "pip install {module}",
    },
    "file_not_found": {
        "pattern": r"FileNotFoundError.*",
        "description": "檔案不存在",
        "auto_fixable": False,
    },
    "permission_denied": {
        "pattern": r"PermissionError.*",
        "description": "權限不足",
        "auto_fixable": True,
        "fix_command": "chmod +x {file}",
    },
    "encoding_error": {
        "pattern": r"UnicodeDecodeError.*",
        "description": "編碼錯誤",
        "auto_fixable": False,
    },
}


class BugFixer:
    """Bug 修復器"""
    
    def __init__(self):
        self.date = datetime.now().strftime("%Y-%m-%d")
        self.time = datetime.now().strftime("%H:%M")
        self.fixes_file = FIXES_DIR / f"fixes_{self.date}.json"
        self.fixes_log = []
        
        FIXES_DIR.mkdir(parents=True, exist_ok=True)
        LOG_DIR.mkdir(parents=True, exist_ok=True)
    
    def log(self, message: str):
        """記錄日誌"""
        log_file = LOG_DIR / f"bug-fixer-{self.date}.log"
        with open(log_file, "a") as f:
            f.write(f"[{self.time}] {message}\n")
        print(f"[{self.time}] {message}")
    
    def scan_error_logs(self) -> list:
        """掃描錯誤日誌"""
        errors = []
        
        # 掃描常見日誌位置
        log_paths = [
            Path("/Users/user/logs/error.log"),
            Path("/Users/user/night-shift/logs/night-shift-error.log"),
        ]
        
        for log_path in log_paths:
            if log_path.exists():
                content = log_path.read_text(encoding="utf-8", errors="ignore")
                lines = content.split("\n")
                
                for line in lines[-100:]:  # 檢查最後100行
                    for issue_type, issue_info in COMMON_ISSUES.items():
                        if re.search(issue_info["pattern"], line):
                            errors.append({
                                "type": issue_type,
                                "message": line.strip(),
                                "source": str(log_path),
                                "auto_fixable": issue_info["auto_fixable"],
                            })
        
        return errors
    
    def analyze_code_issues(self, file_path: str) -> list:
        """分析程式碼問題"""
        issues = []
        
        path = Path(file_path)
        if not path.exists():
            return issues
        
        content = path.read_text(encoding="utf-8", errors="ignore")
        
        # 檢查常見 Python 問題
        if path.suffix == ".py":
            # 檢查是否使用了 print 而非 log
            if "print(" in content and "import logging" in content:
                issues.append({
                    "type": "inconsistent_logging",
                    "message": f"{file_path}: 混用 print 和 logging",
                    "severity": "low",
                })
            
            # 檢查是否有未使用的 import
            import_pattern = r"^import (\w+)|^from (\w+)"
            imports = re.findall(import_pattern, content, re.MULTILINE)
            # 簡化檢查，實際需要 AST 解析
        
        return issues
    
    def apply_fix(self, issue: dict) -> bool:
        """應用修復"""
        issue_type = issue.get("type")
        
        if issue_type == "permission_denied":
            # 提取檔案路徑並添加執行權限
            match = re.search(r"PermissionError: \[Errno 13\] (.+)", issue["message"])
            if match:
                file_path = match.group(1)
                try:
                    os.chmod(file_path, 0o755)
                    self.log(f"✅ 已修復權限: {file_path}")
                    return True
                except Exception as e:
                    self.log(f"❌ 修復失敗: {e}")
                    return False
        
        elif issue_type == "missing_import":
            # 嘗試安裝缺失的模組
            match = re.search(r"No module named '(\w+)'", issue["message"])
            if match:
                module = match.group(1)
                self.log(f"🔧 嘗試安裝模組: {module}")
                # 這裡只是記錄，實際安裝需要謹慎
                return False  # 不自動安裝，需要人工確認
        
        return False
    
    def generate_fix_report(self, errors: list, fixes_applied: list):
        """生成修復報告"""
        report = {
            "date": self.date,
            "time": self.time,
            "errors_found": len(errors),
            "fixes_applied": len(fixes_applied),
            "errors": errors,
            "fixes": fixes_applied,
        }
        
        with open(self.fixes_file, "w") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        
        self.log(f"📝 修復報告已生成: {self.fixes_file}")
    
    def run(self):
        """執行 Bug 修復流程"""
        self.log("🔧 Bug Fixer 啟動...")
        
        # 1. 掃描錯誤日誌
        errors = self.scan_error_logs()
        self.log(f"📊 發現 {len(errors)} 個潛在問題")
        
        # 2. 嘗試自動修復
        fixes_applied = []
        for error in errors:
            if error.get("auto_fixable"):
                self.log(f"🔧 嘗試自動修復: {error['type']}")
                if self.apply_fix(error):
                    fixes_applied.append(error)
            else:
                self.log(f"⚠️ 需要人工處理: {error['type']} - {error['message'][:50]}...")
        
        # 3. 生成報告
        self.generate_fix_report(errors, fixes_applied)
        
        self.log(f"✅ Bug Fixer 完成 - 修復 {len(fixes_applied)}/{len(errors)} 個問題")


def main():
    """主函數"""
    fixer = BugFixer()
    fixer.run()


if __name__ == "__main__":
    main()
