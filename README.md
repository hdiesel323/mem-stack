# Unified Memory Stack

A cohesive memory layer for AI coding agents that integrates eight complementary systems:

| System | Purpose | Timescale/Function |
|--------|---------|-------------------|
| **[SpecStory](https://github.com/specstoryai/getspecstory)** | Conversation history capture | Raw archive (searchable) |
| **[mcp-cli](https://github.com/philschmid/mcp-cli)** | Token-efficient MCP access | MCP infrastructure |
| **[Cartographer](https://github.com/kingbootoshi/cartographer)** | Codebase architecture map | Project structure |
| **[Beads](https://github.com/steveyegge/beads)** | Task dependency graph | Current work |
| **[Memvid](https://github.com/memvid/memvid)** | Long-term knowledge | Days → months |
| **[Claude-Mem](https://github.com/thedotmack/claude-mem)** | Session observations | Minutes → hours |
| **[BMAD](https://github.com/bmad-code-org/BMAD-METHOD)** | Orchestration | Task complexity |

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                     THE COMPLETE STACK                               │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  CAPTURE LAYER                                                       │
│  └── SpecStory         Raw AI conversations → .specstory/history/   │
│                                                                      │
│  INFRASTRUCTURE                                                      │
│  └── mcp-cli           Token-efficient MCP server discovery/calls   │
│                                                                      │
│  MEMORY LAYERS (by timescale)                                       │
│  ├── Claude-Mem        Minutes-hours (session observations)         │
│  ├── Beads             Hours-days (task dependencies)               │
│  └── Memvid            Days-months (long-term decisions)            │
│                                                                      │
│  UNDERSTANDING                                                       │
│  └── Cartographer      Codebase architecture map                    │
│                                                                      │
│  ORCHESTRATION                                                       │
│  └── BMAD              Scale-adaptive agent coordination            │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

## Why Eight Systems?

Each solves a different problem:

```
┌─────────────────────────────────────────────────────────────────┐
│                     PROJECT INIT                                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  /cartographer                                                   │
│           ↓                                                      │
│  docs/CODEBASE_MAP.md created                                   │
│           ↓                                                      │
│  Indexed to Memvid for semantic search                          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│                     SESSION START                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  "Where is authentication handled?"                              │
│           ↓                                                      │
│  Cartographer: query_codebase("auth") → src/auth/, middleware/  │
│                                                                  │
│  "What should I work on?"                                        │
│           ↓                                                      │
│  Beads: bd ready → [task-1, task-2, task-3]                     │
│                                                                  │
│  "What was I doing yesterday?"                                   │
│           ↓                                                      │
│  Claude-Mem: timeline(24h) → [observations...]                  │
│                                                                  │
│  "Why did we choose Postgres?"                                   │
│           ↓                                                      │
│  Memvid: search("postgres decision") → [decision record]        │
│                                                                  │
│  "This looks complex..."                                         │
│           ↓                                                      │
│  BMAD: assess → Level 3, use multi-agent orchestration          │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Quick Start

```bash
# Clone and bootstrap
git clone https://github.com/hdiesel323/mem-stack
cd mem-stack
chmod +x bootstrap.sh
./bootstrap.sh

# Copy CLAUDE.md to your project
cp CLAUDE.md /path/to/your/project/

# Initialize in your project
cd /path/to/your/project
bd init                    # Initialize Beads
specstory run claude       # Launch with conversation capture

# Or use mcp-cli to discover MCP tools
mcp-cli                    # List all available MCP servers/tools
mcp-cli grep "*memory*"    # Search for memory-related tools
```

## Data Flow

### The Memory Pipeline

```
┌─────────────────────────────────────────────────────────────────┐
│  specstory run claude                                            │
│         │                                                        │
│         ▼                                                        │
│  SpecStory captures raw conversation → .specstory/history/       │
│         │                                                        │
│         ├─→ Claude-Mem extracts key observations (session)       │
│         │                                                        │
│         ├─→ Memvid stores long-term decisions/learnings          │
│         │                                                        │
│         └─→ Beads tracks work items discovered                   │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

### Project Initialization

```
/cartographer
    │
    ├─→ Parallel Sonnet subagents analyze codebase
    ├─→ Creates docs/CODEBASE_MAP.md
    └─→ Index to Memvid for semantic search
```

### Session Lifecycle

```
SESSION START
    │
    ├─→ Cartographer: load codebase map
    ├─→ Claude-Mem: load recent summaries
    ├─→ Memvid: query relevant knowledge  
    ├─→ Beads: get ready tasks
    └─→ BMAD: assess complexity level
           │
           ▼
      DURING WORK
           │
    ├─→ "Where is X?" → Query codebase map
    ├─→ Claim task (Beads: atomic)
    ├─→ Work... Claude-Mem captures observations
    ├─→ Need history? → Query Memvid
    ├─→ Discover new work? → bd create --discovered-from
    └─→ Complete? → bd close
           │
           ▼
     SESSION END
           │
    ├─→ Generate summary
    ├─→ Extract learnings → append to Memvid
    ├─→ Beads auto-syncs to git
    └─→ SpecStory has full conversation
```

### After Major Changes

```
memory:refresh_codebase_map
    │
    ├─→ Cartographer update mode (only changed files)
    └─→ Re-index to Memvid
```

### Query Routing

The unified MCP server automatically routes queries:

| Query Pattern | Routes To | Example |
|--------------|-----------|---------|
| Architecture | Cartographer | "Where is auth?", "Project structure" |
| Work state | Beads | "What's ready?", "What's blocked?" |
| Recent activity | Claude-Mem | "What did I just do?", "Earlier today" |
| Historical | Memvid | "Why did we choose X?", "History of Y" |
| Complexity | BMAD | "Is this complex?", "How to approach?" |

## File Locations

```
your-project/
├── .specstory/
│   └── history/         # Raw conversation archive (searchable)
├── docs/
│   └── CODEBASE_MAP.md  # Cartographer output (git-tracked)
├── .beads/
│   ├── beads.jsonl      # Task graph (git-tracked)
│   └── beads.db         # SQLite cache (gitignored)
├── .memvid/
│   └── knowledge.mv2    # Long-term memory (git-tracked)
├── .claude-mem/
│   └── sessions.db      # Session observations (gitignored)
├── .bmad/
│   ├── config.yaml      # BMAD configuration
│   └── agents/          # Custom agent definitions
├── .mcp/
│   └── unified_memory_mcp.py
├── mcp_servers.json     # mcp-cli configuration
├── .mcp.json            # MCP server configuration
└── CLAUDE.md            # Instructions for Claude
```

## MCP Tools

The unified MCP server exposes these tools:

### Session Management

```
memory:start_session     - Initialize with all contexts
memory:end_session       - Persist learnings, sync all systems
```

### Codebase Understanding (Cartographer)

```
memory:get_codebase_map       - Get full architecture map
memory:query_codebase         - Search for specific files/modules
memory:refresh_codebase_map   - Update map after code changes
memory:index_codebase_to_memory - Index map to Memvid
```

### Queries

```
memory:query             - Smart routing based on question
memory:search_knowledge  - Direct Memvid search
memory:get_recent        - Direct Claude-Mem query
```

### Task Management

```
memory:task_ready        - Get ready tasks from Beads
memory:task_create       - Create with provenance linking
memory:task_close        - Close and update dependencies
```

### Knowledge Capture

```
memory:log_decision      - Record decision for long-term memory
```

## Integration Points

### Beads → Memvid

When completing significant tasks, learnings are extracted and persisted:

```python
# On task complete with detailed summary
await on_task_complete(memory, "bd-a1b2", "Implemented OAuth2...")
# → Automatically appends to Memvid if summary is substantial
```

### Claude-Mem → Session Context

Claude-Mem's lifecycle hooks bridge to the unified system:

```python
CLAUDE_MEM_HOOK_MAPPING = {
    "SessionStart": on_session_start,  # Load all contexts
    "Stop": on_session_end,            # Persist learnings
    "SessionEnd": on_session_end,      # Final cleanup
}
```

### BMAD → Task Selection

BMAD complexity assessment influences task approach:

```python
level = memory._assess_complexity(ready_tasks)
# L0: Direct execution
# L1: Single agent
# L2: Specialized agent
# L3: Multi-agent
# L4: Full orchestration
```

## Examples

### Starting a Session

```python
# Via MCP tool
result = await memory.start_session(task_hint="auth system")

# Returns:
{
    "ready_tasks": [...],
    "recent_context": [...],
    "relevant_knowledge": [...],  # From Memvid based on hint
    "recommended_level": 2        # BMAD complexity
}
```

### Recording a Decision

```python
await memory.log_decision(
    topic="database-choice",
    decision="PostgreSQL",
    rationale="Need ACID transactions for financial data",
    alternatives_considered=["MongoDB", "SQLite"]
)
# → Persisted to Memvid, retrievable later
```

### Discovering Work

```python
# While on task bd-a1b2, discover need for validation
await memory.task_create(
    title="Add input validation",
    task_type="task",
    priority=2,
    discovered_from="bd-a1b2"  # Provenance link
)
# → Creates bd-xxxx with discovered-from dependency
```

## Best Practices

### Do

- ✅ Start sessions with `memory:start_session`
- ✅ Log significant decisions with `memory:log_decision`
- ✅ Use `--discovered-from` when creating related tasks
- ✅ End sessions properly to persist learnings
- ✅ Query Memvid before re-making past decisions

### Don't

- ❌ Create markdown TODO files (use Beads)
- ❌ Rely on conversation history alone (use Claude-Mem)
- ❌ Re-discover past decisions (query Memvid first)
- ❌ Tackle L3+ tasks without BMAD assessment
- ❌ Close tasks without checking downstream dependencies

## Troubleshooting

### Beads not syncing

```bash
# Force sync
bd sync

# Check daemon status
bd daemon status
```

### Memvid not finding results

```bash
# Check store exists
ls -la .memvid/knowledge.mv2

# Rebuild index
memvid reindex .memvid/knowledge.mv2
```

### Claude-Mem not responding

```bash
# Check service
curl http://localhost:37777/health

# Restart via Claude Code
claude mcp restart claude-mem
```

## Contributing

PRs welcome! Areas of interest:

- [ ] BMAD deep integration (invoke specific agents)
- [ ] SpecStory → Memvid pipeline (extract learnings from conversations)
- [ ] mcp-cli integration for dynamic tool discovery
- [ ] Web UI for knowledge exploration
- [ ] Cross-project memory federation
- [ ] RAG over SpecStory archive

## License

MIT
