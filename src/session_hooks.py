#!/usr/bin/env python3
"""
Unified Memory Stack - Session Lifecycle Hooks

Integrates Claude-Mem lifecycle events with the unified memory system.
Loads contexts from all systems on session start, persists learnings on end.
"""

import json
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Optional

# Project paths
PROJECT_ROOT = Path.cwd()
BEADS_DIR = PROJECT_ROOT / ".beads"
MEMVID_DIR = PROJECT_ROOT / ".memvid"
DOCS_DIR = PROJECT_ROOT / "docs"


def on_session_start(context: Optional[dict] = None) -> dict:
    """
    Load contexts from all memory systems at session start.

    Called by Claude-Mem's SessionStart hook.

    Args:
        context: Optional context from Claude-Mem containing project info

    Returns:
        Unified context from all memory systems
    """
    result = {
        "timestamp": datetime.now().isoformat(),
        "ready_tasks": [],
        "codebase_summary": None,
        "recent_decisions": [],
        "system_status": {}
    }

    # Load ready tasks from Beads
    try:
        proc = subprocess.run(
            ["bd", "ready", "--json"],
            capture_output=True, text=True, timeout=10
        )
        if proc.returncode == 0 and proc.stdout.strip():
            result["ready_tasks"] = json.loads(proc.stdout)
            result["system_status"]["beads"] = "ok"
    except FileNotFoundError:
        result["system_status"]["beads"] = "not_installed"
    except Exception as e:
        result["system_status"]["beads"] = f"error: {str(e)}"

    # Load codebase summary from Cartographer
    codebase_map = DOCS_DIR / "CODEBASE_MAP.md"
    if codebase_map.exists():
        content = codebase_map.read_text()
        # Extract summary section (first ~20 lines usually)
        lines = content.split("\n")[:30]
        result["codebase_summary"] = "\n".join(lines)
        result["system_status"]["cartographer"] = "ok"
    else:
        result["system_status"]["cartographer"] = "no_map"

    # Check Memvid status
    knowledge_file = MEMVID_DIR / "knowledge.mv2"
    if knowledge_file.exists():
        result["system_status"]["memvid"] = "ok"
    else:
        result["system_status"]["memvid"] = "empty"

    return result


def on_session_end(summary: Optional[str] = None, learnings: Optional[list] = None) -> dict:
    """
    Persist learnings to Memvid and sync systems at session end.

    Called by Claude-Mem's Stop or SessionEnd hooks.

    Args:
        summary: Session summary text
        learnings: List of key learnings/decisions from the session

    Returns:
        Sync status for each system
    """
    result = {
        "timestamp": datetime.now().isoformat(),
        "synced": [],
        "persisted": [],
        "errors": []
    }

    # Sync Beads to git
    try:
        proc = subprocess.run(
            ["bd", "sync"],
            capture_output=True, text=True, timeout=30
        )
        if proc.returncode == 0:
            result["synced"].append("beads")
    except Exception as e:
        result["errors"].append(f"beads_sync: {str(e)}")

    # Persist learnings to Memvid
    if learnings:
        knowledge_file = MEMVID_DIR / "knowledge.mv2"
        for learning in learnings:
            if len(learning) > 50:  # Only persist substantial learnings
                try:
                    subprocess.run(
                        ["memvid", "append", str(knowledge_file), learning],
                        capture_output=True, timeout=30
                    )
                    result["persisted"].append(learning[:50] + "...")
                except Exception as e:
                    result["errors"].append(f"memvid_append: {str(e)}")

    # Persist summary if substantial
    if summary and len(summary) > 100:
        knowledge_file = MEMVID_DIR / "knowledge.mv2"
        try:
            dated_summary = f"[{datetime.now().strftime('%Y-%m-%d')}] {summary}"
            subprocess.run(
                ["memvid", "append", str(knowledge_file), dated_summary],
                capture_output=True, timeout=30
            )
            result["persisted"].append("session_summary")
        except Exception as e:
            result["errors"].append(f"memvid_summary: {str(e)}")

    return result


# Claude-Mem hook mapping
CLAUDE_MEM_HOOK_MAPPING = {
    "SessionStart": on_session_start,
    "Stop": on_session_end,
    "SessionEnd": on_session_end,
}


def handle_hook(hook_name: str, payload: Optional[dict] = None) -> dict:
    """
    Main entry point for Claude-Mem hooks.

    Args:
        hook_name: Name of the Claude-Mem lifecycle hook
        payload: Hook payload data

    Returns:
        Result from the appropriate handler
    """
    handler = CLAUDE_MEM_HOOK_MAPPING.get(hook_name)
    if handler:
        return handler(payload or {})
    return {"error": f"Unknown hook: {hook_name}"}


if __name__ == "__main__":
    # Test hooks
    import sys

    if len(sys.argv) > 1:
        hook = sys.argv[1]
        result = handle_hook(hook)
        print(json.dumps(result, indent=2))
    else:
        print("Usage: session_hooks.py <hook_name>")
        print("Available hooks: SessionStart, Stop, SessionEnd")
