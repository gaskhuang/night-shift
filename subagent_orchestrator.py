#!/usr/bin/env python3
# 🎛️ Subagent 調度器
# 夜班系統的核心調度器，負責呼叫不同 AI 模型執行任務

import os
import sys
import json
import subprocess
from datetime import datetime
from pathlib import Path

# 配置
NIGHT_SHIFT_DIR = Path("/Users/user/night-shift")
LOG_DIR = NIGHT_SHIFT_DIR / "logs"
DISCUSSION_DIR = NIGHT_SHIFT_DIR / "discussion"
REPORTS_DIR = NIGHT_SHIFT_DIR / "reports"

# 模型配置
MODELS = {
    "tech_lead": {
        "name": "Claude Sonnet 4-6",
        "role": "技術決策、程式修復、系統分析",
        "priority": "高",
    },
    "pm": {
        "name": "GPT-4.5",
        "role": "統整、分析、文章撰寫、知識庫整理",
        "priority": "高",
    },
    "researcher": {
        "name": "Grok",
        "role": "爬蟲、資料蒐集、網路研究",
        "priority": "中",
    },
    "coder": {
        "name": "Codex",
        "role": "程式生成、Code Review、自動化腳本",
        "priority": "中",
    },
}

# 安全護欄 - 禁止的操作
FORBIDDEN_ACTIONS = [
    "rm -rf /",
    "rm -rf ~",
    "rm -rf /Users",
    "rm -rf /System",
    "deploy.*production",
    "git push.*--force",
    "send.*message",
    "api_key",
    "apikey",
]


class SafetyGuardian:
    """安全守護 - 檢查所有操作是否安全"""
    
    @staticmethod
    def check_command(command: str) -> tuple[bool, str]:
        """檢查命令是否安全"""
        command_lower = command.lower()
        
        for forbidden in FORBIDDEN_ACTIONS:
            if forbidden in command_lower:
                return False, f"檢測到禁止操作: {forbidden}"
        
        return True, "安全"
    
    @staticmethod
    def log_action(action: str, status: str, details: str = ""):
        """記錄操作"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_file = LOG_DIR / f"safety-{datetime.now().strftime('%Y-%m-%d')}.log"
        
        with open(log_file, "a") as f:
            f.write(f"[{timestamp}] {action}: {status}")
            if details:
                f.write(f" - {details}")
            f.write("\n")


class NightShiftOrchestrator:
    """夜班調度器 - 管理所有 subagent 的執行"""
    
    def __init__(self):
        self.date = datetime.now().strftime("%Y-%m-%d")
        self.time = datetime.now().strftime("%H:%M")
        self.safety = SafetyGuardian()
        self.discussion_file = DISCUSSION_DIR / f"collaboration_{self.date}.md"
        
        # 確保目錄存在
        LOG_DIR.mkdir(parents=True, exist_ok=True)
        DISCUSSION_DIR.mkdir(parents=True, exist_ok=True)
        REPORTS_DIR.mkdir(parents=True, exist_ok=True)
    
    def log(self, message: str):
        """記錄日誌"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        log_file = LOG_DIR / f"orchestrator-{self.date}.log"
        
        with open(log_file, "a") as f:
            f.write(f"[{timestamp}] {message}\n")
        
        print(f"[{timestamp}] {message}")
    
    def add_to_discussion(self, agent: str, message: str):
        """添加訊息到討論區"""
        timestamp = datetime.now().strftime("%H:%M")
        
        with open(self.discussion_file, "a") as f:
            f.write(f"\n### {agent} ({timestamp}):\n")
            f.write(f"{message}\n")
    
    def spawn_subagent(self, agent_type: str, task: str, context: dict = None) -> dict:
        """
        生成 subagent 執行任務
        
        Args:
            agent_type: tech_lead, pm, researcher, coder
            task: 任務描述
            context: 額外上下文
        
        Returns:
            執行結果
        """
        if agent_type not in MODELS:
            return {"success": False, "error": f"未知的 agent 類型: {agent_type}"}
        
        model_info = MODELS[agent_type]
        self.log(f"🤖 生成 {agent_type} ({model_info['name']}) 執行: {task[:50]}...")
        
        # 安全檢查
        is_safe, reason = self.safety.check_command(task)
        if not is_safe:
            self.safety.log_action(f"BLOCKED: {task}", "DENIED", reason)
            self.add_to_discussion(agent_type, f"⚠️ 任務被安全護欄攔截: {reason}")
            return {"success": False, "error": reason, "blocked": True}
        
        # 記錄到討論區
        self.add_to_discussion(agent_type, f"開始執行: {task}")
        
        # 這裡是 subagent 執行的核心邏輯
        # 實際上會呼叫對應的 AI 模型
        result = self._execute_subagent_task(agent_type, task, context)
        
        # 記錄結果
        status = "✅ 完成" if result.get("success") else "❌ 失敗"
        self.add_to_discussion(agent_type, f"{status}: {result.get('summary', '無摘要')}")
        
        return result
    
    def _execute_subagent_task(self, agent_type: str, task: str, context: dict = None) -> dict:
        """
        實際執行 subagent 任務
        這裡會根據不同的 agent_type 呼叫不同的處理邏輯
        """
        # 這是一個模板，實際執行會依賴外部 AI 模型
        # 這裡回傳一個結構化的結果
        
        return {
            "success": True,
            "agent": agent_type,
            "task": task,
            "summary": f"[{agent_type}] 任務已執行完成",
            "outputs": [],
            "timestamp": datetime.now().isoformat(),
        }
    
    def execute_round(self, round_num: int):
        """執行指定輪次的任務"""
        self.log(f"🌙 Round {round_num} 開始執行")
        
        round_tasks = {
            1: self._round_1_system_check,
            2: self._round_2_tech_patrol,
            3: self._round_3_knowledge_update,
            4: self._round_4_research,
            5: self._round_5_content,
            6: self._round_6_documentation,
            7: self._round_7_proposals,
            8: self._round_8_morning_report,
        }
        
        if round_num in round_tasks:
            round_tasks[round_num]()
        else:
            self.log(f"❌ 未知輪次: {round_num}")
    
    def _round_1_system_check(self):
        """Round 1: 系統檢查 + 待辦清單抓取"""
        self.spawn_subagent("tech_lead", "執行系統狀態檢查，包括磁碟、記憶體、服務狀態")
        self.spawn_subagent("pm", "抓取 Google Tasks 待辦清單，同步到 TASK_LIST.md")
    
    def _round_2_tech_patrol(self):
        """Round 2: Tech Lead 巡邏 & 修復"""
        self.spawn_subagent("tech_lead", "分析今日錯誤日誌，識別可自動修復的問題")
        self.spawn_subagent("coder", "對識別的問題進行自動修復")
    
    def _round_3_knowledge_update(self):
        """Round 3: PM 知識庫整理"""
        self.spawn_subagent("pm", "整理 memory/ 目錄，更新 second_brain.md 和 lobster_second_brain.md")
    
    def _round_4_research(self):
        """Round 4: 研究任務 (AEO/GEO/SEO)"""
        self.spawn_subagent("researcher", "搜尋 AEO (Answer Engine Optimization) 最新趨勢")
        self.spawn_subagent("researcher", "搜尋 GEO (Generative Engine Optimization) 最新趨勢")
        self.spawn_subagent("pm", "整合研究結果到 aeo_insights.md 和 geo_insights.md")
    
    def _round_5_content(self):
        """Round 5: 內容生成"""
        self.spawn_subagent("pm", "根據研究結果撰寫部落格文章草稿")
    
    def _round_6_documentation(self):
        """Round 6: 文件整理 & SOP更新"""
        self.spawn_subagent("pm", "更新文件、檢查並優化現有 SOP")
    
    def _round_7_proposals(self):
        """Round 7: 提案準備"""
        self.spawn_subagent("tech_lead", "準備技術優化提案")
        self.spawn_subagent("pm", "準備管理和流程優化提案")
    
    def _round_8_morning_report(self):
        """Round 8: 晨報生成"""
        self.spawn_subagent("pm", "彙整整夜工作成果，生成晨報")
        self.log("✅ 夜班完成，晨報已生成")


def main():
    """主函數"""
    if len(sys.argv) < 2:
        print("用法: python subagent_orchestrator.py <round_num|status>")
        print("  round_num: 1-8 執行指定輪次")
        print("  status: 顯示系統狀態")
        sys.exit(1)
    
    command = sys.argv[1]
    orchestrator = NightShiftOrchestrator()
    
    if command == "status":
        print("🌙 AI 夜班系統狀態")
        print("=" * 40)
        print(f"日期: {orchestrator.date}")
        print(f"時間: {orchestrator.time}")
        print(f"討論區: {orchestrator.discussion_file}")
        print()
        print("可用模型:")
        for key, model in MODELS.items():
            print(f"  • {key}: {model['name']}")
            print(f"    角色: {model['role']}")
    
    elif command.isdigit():
        round_num = int(command)
        orchestrator.execute_round(round_num)
    
    else:
        print(f"❌ 未知命令: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
