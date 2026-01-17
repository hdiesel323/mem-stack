#!/usr/bin/env python3
"""
Unified Memory Stack - MCP Integration Server

Routes queries intelligently across 8 memory systems:
- Beads: Task dependency graph (current work)
- Memvid: Long-term knowledge (days-months)
- Claude-Mem: Session observations (minutes-hours)
- Cartographer: Codebase architecture map
- SpecStory: Raw conversation archive
- mcp-cli: MCP infrastructure
- BMAD: Orchestration complexity assessment
"""

import asyncio
import json
import os
import subprocess
from datetime import datetime
from pathlib import Path
from typing import Any, Optional

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import Tool, TextContent
except ImportError:
    print("Error: MCP package not installed. Run: pip3 install mcp")
    exit(1)

# Initialize MCP server
server = Server("unified-memory")

# Project paths
PROJECT_ROOT = Path.cwd()
BEADS_DIR = PROJECT_ROOT / ".beads"
MEMVID_DIR = PROJECT_ROOT / ".memvid"
CLAUDE_MEM_DIR = PROJECT_ROOT / ".claude-mem"
SPECSTORY_DIR = PROJECT_ROOT / ".specstory"
DOCS_DIR = PROJECT_ROOT / "docs"


class UnifiedMemory:
    """Unified interface to all memory systems."""

    def __init__(self):
        self.session_id: Optional[str] = None
        self.session_start: Optional[datetime] = None

    async def start_session(self, task_hint: Optional[str] = None) -> dict:
        """Initialize session with contexts from all memory systems."""
        self.session_id = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.session_start = datetime.now()

        result = {
            "session_id": self.session_id,
            "ready_tasks": await self._get_ready_tasks(),
            "recent_context": await self._get_recent_context(),
            "relevant_knowledge": [],
            "recommended_level": 0
        }

        # Query Memvid if task hint provided
        if task_hint:
            result["relevant_knowledge"] = await self._search_knowledge(task_hint)

        # Assess complexity
        result["recommended_level"] = self._assess_complexity(result["ready_tasks"])

        return result

    async def end_session(self, summary: Optional[str] = None) -> dict:
        """Persist learnings and sync all systems."""
        result = {"synced": []}

        # Sync Beads
        try:
            subprocess.run(["bd", "sync"], capture_output=True, timeout=30)
            result["synced"].append("beads")
        except Exception:
            pass

        # Persist substantial summary to Memvid
        if summary and len(summary) > 100:
            await self._append_to_memvid(summary)
            result["synced"].append("memvid")

        self.session_id = None
        self.session_start = None
        return result

    async def query(self, question: str) -> dict:
        """Smart query routing based on question content."""
        question_lower = question.lower()

        # Route to appropriate system
        if any(w in question_lower for w in ["where is", "structure", "architecture", "file", "module"]):
            return {"source": "cartographer", "result": await self._query_codebase(question)}

        if any(w in question_lower for w in ["ready", "blocked", "task", "work on", "todo"]):
            return {"source": "beads", "result": await self._get_ready_tasks()}

        if any(w in question_lower for w in ["just", "earlier", "today", "recent", "session"]):
            return {"source": "claude-mem", "result": await self._get_recent_context()}

        if any(w in question_lower for w in ["why", "decision", "chose", "history", "before"]):
            return {"source": "memvid", "result": await self._search_knowledge(question)}

        if any(w in question_lower for w in ["complex", "approach", "level", "orchestrat"]):
            tasks = await self._get_ready_tasks()
            return {"source": "bmad", "result": {"level": self._assess_complexity(tasks)}}

        # Default: search across all
        return {
            "source": "unified",
            "result": {
                "beads": await self._get_ready_tasks(),
                "recent": await self._get_recent_context(),
                "knowledge": await self._search_knowledge(question)
            }
        }

    async def _get_ready_tasks(self) -> list:
        """Get ready tasks from Beads."""
        try:
            result = subprocess.run(
                ["bd", "ready", "--json"],
                capture_output=True, text=True, timeout=10
            )
            if result.returncode == 0 and result.stdout.strip():
                return json.loads(result.stdout)
        except Exception:
            pass
        return []

    async def _get_recent_context(self) -> list:
        """Get recent observations from Claude-Mem."""
        # Claude-Mem integration via its MCP interface
        # For now, return empty - actual implementation depends on claude-mem API
        return []

    async def _search_knowledge(self, query: str) -> list:
        """Search Memvid for relevant knowledge."""
        try:
            result = subprocess.run(
                ["memvid", "search", str(MEMVID_DIR / "knowledge.mv2"), query],
                capture_output=True, text=True, timeout=30
            )
            if result.returncode == 0 and result.stdout.strip():
                return result.stdout.strip().split("\n")
        except Exception:
            pass
        return []

    async def _query_codebase(self, query: str) -> dict:
        """Query Cartographer codebase map."""
        codebase_map = DOCS_DIR / "CODEBASE_MAP.md"
        if codebase_map.exists():
            content = codebase_map.read_text()
            # Simple keyword search in map
            query_terms = query.lower().split()
            relevant_lines = []
            for line in content.split("\n"):
                if any(term in line.lower() for term in query_terms):
                    relevant_lines.append(line)
            return {"map_exists": True, "matches": relevant_lines[:10]}
        return {"map_exists": False, "matches": []}

    async def _append_to_memvid(self, content: str) -> bool:
        """Append content to Memvid knowledge store."""
        try:
            knowledge_file = MEMVID_DIR / "knowledge.mv2"
            subprocess.run(
                ["memvid", "append", str(knowledge_file), content],
                capture_output=True, timeout=30
            )
            return True
        except Exception:
            return False

    def _assess_complexity(self, tasks: list) -> int:
        """BMAD-style complexity assessment (0-4)."""
        if not tasks:
            return 0

        # Simple heuristic based on task count and dependencies
        task_count = len(tasks)
        has_deps = any(t.get("dependencies", []) for t in tasks if isinstance(t, dict))

        if task_count <= 1 and not has_deps:
            return 0  # L0: Direct execution
        if task_count <= 3:
            return 1  # L1: Single agent
        if task_count <= 5:
            return 2  # L2: Specialized agent
        if task_count <= 10:
            return 3  # L3: Multi-agent
        return 4  # L4: Full orchestration


# Global memory instance
memory = UnifiedMemory()


@server.list_tools()
async def list_tools() -> list[Tool]:
    """List available unified memory tools."""
    return [
        Tool(
            name="memory:start_session",
            description="Initialize session with all memory contexts",
            inputSchema={
                "type": "object",
                "properties": {
                    "task_hint": {"type": "string", "description": "Optional hint for relevant knowledge lookup"}
                }
            }
        ),
        Tool(
            name="memory:end_session",
            description="Persist learnings and sync all systems",
            inputSchema={
                "type": "object",
                "properties": {
                    "summary": {"type": "string", "description": "Session summary to persist"}
                }
            }
        ),
        Tool(
            name="memory:query",
            description="Smart query routing across all memory systems",
            inputSchema={
                "type": "object",
                "properties": {
                    "question": {"type": "string", "description": "Question to route and answer"}
                },
                "required": ["question"]
            }
        ),
        Tool(
            name="memory:task_ready",
            description="Get ready tasks from Beads",
            inputSchema={"type": "object", "properties": {}}
        ),
        Tool(
            name="memory:search_knowledge",
            description="Search Memvid long-term knowledge",
            inputSchema={
                "type": "object",
                "properties": {
                    "query": {"type": "string", "description": "Search query"}
                },
                "required": ["query"]
            }
        ),
        Tool(
            name="memory:log_decision",
            description="Record decision for long-term memory",
            inputSchema={
                "type": "object",
                "properties": {
                    "topic": {"type": "string"},
                    "decision": {"type": "string"},
                    "rationale": {"type": "string"},
                    "alternatives_considered": {"type": "array", "items": {"type": "string"}}
                },
                "required": ["topic", "decision", "rationale"]
            }
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Handle tool calls."""
    result: Any = None

    if name == "memory:start_session":
        result = await memory.start_session(arguments.get("task_hint"))
    elif name == "memory:end_session":
        result = await memory.end_session(arguments.get("summary"))
    elif name == "memory:query":
        result = await memory.query(arguments["question"])
    elif name == "memory:task_ready":
        result = await memory._get_ready_tasks()
    elif name == "memory:search_knowledge":
        result = await memory._search_knowledge(arguments["query"])
    elif name == "memory:log_decision":
        content = f"DECISION: {arguments['topic']}\n"
        content += f"Choice: {arguments['decision']}\n"
        content += f"Rationale: {arguments['rationale']}\n"
        if arguments.get("alternatives_considered"):
            content += f"Alternatives: {', '.join(arguments['alternatives_considered'])}\n"
        await memory._append_to_memvid(content)
        result = {"logged": True, "topic": arguments["topic"]}
    else:
        result = {"error": f"Unknown tool: {name}"}

    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def main():
    """Run the MCP server."""
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
