# Unified Memory Stack

A cohesive memory layer for AI coding agents that integrates eight complementary systems into one install.

## Quick Install

```bash
# In your project directory
curl -fsSL https://raw.githubusercontent.com/hdiesel323/mem-stack/main/install.sh | bash
```

That's it. The installer sets up everything automatically.

## What Gets Installed

| System | Purpose | Data Location |
|--------|---------|---------------|
| **[Beads](https://github.com/steveyegge/beads)** | Task dependency graph | `.beads/` |
| **[Memvid](https://github.com/memvid/memvid)** | Long-term knowledge | `.memvid/` |
| **[Claude-Mem](https://github.com/thedotmack/claude-mem)** | Session observations | `.claude-mem/` |
| **[SpecStory](https://github.com/specstoryai/getspecstory)** | Conversation archive | `.specstory/` |
| **[Cartographer](https://github.com/kingbootoshi/cartographer)** | Codebase mapping | `docs/CODEBASE_MAP.md` |
| **[mcp-cli](https://github.com/philschmid/mcp-cli)** | MCP tool discovery | CLI tool |
| **[BMAD](https://github.com/bmad-code-org/BMAD-METHOD)** | Task orchestration | `.bmad/` |
| **Unified MCP** | Integration layer | `.mcp/` |

## Setup Guide

### 1. Install in Your Project

```bash
cd /path/to/your/project
curl -fsSL https://raw.githubusercontent.com/hdiesel323/mem-stack/main/install.sh | bash
```

### 2. Initialize Beads (Task Tracking)

```bash
bd init
```

### 3. Map Your Codebase (in Claude Code)

```
/cartographer
```

This creates `docs/CODEBASE_MAP.md` with your project's architecture.

### 4. Optional: Install BMAD (if skipped during install)

```bash
npx bmad-method@alpha install
```

### 5. Start Working

```bash
# Launch Claude with conversation capture
specstory run claude

# Or just use Claude Code directly - memory stack is ready
```

## Directory Structure After Install

```
your-project/
├── .beads/              # Task graph (git-tracked)
├── .memvid/             # Long-term knowledge
├── .claude-mem/         # Session observations (gitignored)
├── .specstory/history/  # Conversation archive
├── .bmad/agents/        # BMAD orchestration
├── .mcp/
│   ├── unified_memory_mcp.py
│   └── session_hooks.py
├── .mcp.json            # MCP server config
├── .gitignore           # Updated with memory stack entries
├── CLAUDE.md            # Agent instructions
└── docs/
    └── CODEBASE_MAP.md  # After running /cartographer
```

## Daily Workflow

### Starting a Session

```bash
# Check what's ready to work on
bd ready

# See task details
bd show <task-id>

# Claim a task
bd update <task-id> --status in-progress
```

### During Work

```bash
# Found new work while on a task?
bd create "New task title" --discovered-from <current-task-id>

# Need to block current task?
bd update <task-id> --status blocked --blocked-by <blocker-id>
```

### Completing Work

```bash
# Close with summary (persists to long-term memory)
bd close <task-id> --summary "Implemented X by doing Y"

# Sync to git
bd sync
```

### Querying Memory

The unified MCP server routes questions automatically:

| Question Type | Routes To | Example |
|--------------|-----------|---------|
| Code location | Cartographer | "Where is authentication?" |
| Current tasks | Beads | "What's ready to work on?" |
| Recent activity | Claude-Mem | "What did I just do?" |
| Past decisions | Memvid | "Why did we choose Postgres?" |

## Install Options

```bash
# Minimal install (skip optional components)
curl ... | bash -s -- --minimal

# Skip specific components
curl ... | bash -s -- --no-specstory --no-bmad

# Available flags:
#   --no-specstory    Skip conversation capture
#   --no-mcp-cli      Skip MCP CLI tool
#   --no-cartographer Skip codebase mapping
#   --no-beads        Skip task tracking
#   --no-memvid       Skip long-term memory
#   --no-claude-mem   Skip session memory
#   --no-bmad         Skip orchestration
#   --minimal         Only core components
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    MEMORY TIMESCALES                             │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  Minutes-Hours     Claude-Mem      Session observations          │
│        ↓                                                         │
│  Hours-Days        Beads           Task dependencies             │
│        ↓                                                         │
│  Days-Months       Memvid          Long-term decisions           │
│        ↓                                                         │
│  Permanent         SpecStory       Raw conversation archive      │
│                                                                  │
├─────────────────────────────────────────────────────────────────┤
│                    UNDERSTANDING                                 │
│  Cartographer      Codebase architecture map                     │
│  BMAD              Complexity assessment & orchestration         │
└─────────────────────────────────────────────────────────────────┘
```

## MCP Tools Reference

### Session Management
```
memory:start_session     Initialize with all contexts
memory:end_session       Persist learnings, sync systems
```

### Queries
```
memory:query             Smart routing based on question
memory:search_knowledge  Direct Memvid search
memory:task_ready        Get ready tasks from Beads
```

### Recording
```
memory:log_decision      Record decision for long-term memory
memory:task_create       Create task with provenance linking
memory:task_close        Close and update dependencies
```

## Troubleshooting

### Install fails with 404
GitHub CDN caching. Wait 2-3 minutes or add cache-busting:
```bash
curl -fsSL "https://raw.githubusercontent.com/hdiesel323/mem-stack/main/install.sh?$(date +%s)" | bash
```

### MCP server won't start
Requires Python 3.10+. Check version:
```bash
python3 --version
pip3 install mcp httpx
```

### Beads not syncing
```bash
bd sync
bd daemon status
```

### BMAD install hangs
BMAD has interactive prompts. Run directly in terminal:
```bash
npx bmad-method@alpha install
```

## Requirements

- **Git** - for Beads sync
- **Python 3.10+** - for MCP server
- **Node.js** - for BMAD (optional)
- **Homebrew** (macOS) or **curl** - for component installs

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

Areas of interest:
- SpecStory → Memvid pipeline (extract learnings)
- Web UI for knowledge exploration
- Cross-project memory federation

## License

MIT
