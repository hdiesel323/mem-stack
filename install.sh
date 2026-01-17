#!/bin/bash
# =============================================================================
# Unified Memory Stack - Quick Install
# 
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/hdiesel323/mem-stack/main/install.sh | bash
#
# Or with options:
#   curl -fsSL ... | bash -s -- --no-specstory --no-bmad
# =============================================================================

set -e

REPO_URL="https://github.com/hdiesel323/mem-stack"
REPO_RAW="https://raw.githubusercontent.com/hdiesel323/mem-stack/main"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Unified Memory Stack - Quick Install                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Parse arguments
INSTALL_SPECSTORY=true
INSTALL_MCPCLI=true
INSTALL_CARTOGRAPHER=true
INSTALL_BEADS=true
INSTALL_MEMVID=true
INSTALL_CLAUDEMEM=true
INSTALL_BMAD=true

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-specstory) INSTALL_SPECSTORY=false; shift ;;
        --no-mcp-cli) INSTALL_MCPCLI=false; shift ;;
        --no-cartographer) INSTALL_CARTOGRAPHER=false; shift ;;
        --no-beads) INSTALL_BEADS=false; shift ;;
        --no-memvid) INSTALL_MEMVID=false; shift ;;
        --no-claude-mem) INSTALL_CLAUDEMEM=false; shift ;;
        --no-bmad) INSTALL_BMAD=false; shift ;;
        --minimal) 
            INSTALL_SPECSTORY=false
            INSTALL_BMAD=false
            INSTALL_CARTOGRAPHER=false
            shift ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Check we're in a git repo or project directory
if [ ! -d ".git" ] && [ ! -f "package.json" ] && [ ! -f "pyproject.toml" ] && [ ! -f "Cargo.toml" ]; then
    echo -e "${YELLOW}Warning: Not in a recognized project directory.${NC}"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# -----------------------------------------------------------------------------
# Install components
# -----------------------------------------------------------------------------

echo -e "${GREEN}Installing components...${NC}"
echo ""

# SpecStory
if [ "$INSTALL_SPECSTORY" = true ]; then
    echo -e "${BLUE}[1/7] SpecStory (conversation capture)${NC}"
    if command -v specstory &> /dev/null; then
        echo "  ✓ Already installed"
    else
        if command -v brew &> /dev/null; then
            brew tap specstoryai/tap 2>/dev/null || true
            brew install specstory 2>/dev/null || echo "  Note: Install manually: brew install specstoryai/tap/specstory"
        else
            curl -fsSL https://raw.githubusercontent.com/specstoryai/getspecstory/main/install.sh | bash 2>/dev/null || echo "  Note: Install manually from https://github.com/specstoryai/getspecstory"
        fi
    fi
    mkdir -p .specstory/history
fi

# mcp-cli
if [ "$INSTALL_MCPCLI" = true ]; then
    echo -e "${BLUE}[2/7] mcp-cli (MCP infrastructure)${NC}"
    if command -v mcp-cli &> /dev/null; then
        echo "  ✓ Already installed"
    else
        curl -fsSL https://raw.githubusercontent.com/philschmid/mcp-cli/main/install.sh | bash 2>/dev/null || echo "  Note: Install manually from https://github.com/philschmid/mcp-cli"
    fi
fi

# Cartographer
if [ "$INSTALL_CARTOGRAPHER" = true ]; then
    echo -e "${BLUE}[3/7] Cartographer (codebase mapping)${NC}"
    pip3 install tiktoken --quiet 2>/dev/null || pip3 install tiktoken
    if command -v claude &> /dev/null; then
        echo "  Run in Claude Code: /plugin marketplace add kingbootoshi/cartographer"
        echo "  Then: /plugin install cartographer"
    fi
fi

# Beads
if [ "$INSTALL_BEADS" = true ]; then
    echo -e "${BLUE}[4/7] Beads (task graph)${NC}"
    if command -v bd &> /dev/null; then
        echo "  ✓ Already installed"
    else
        curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash 2>/dev/null || echo "  Note: Install manually from https://github.com/steveyegge/beads"
    fi
    pip3 install beads-mcp --quiet 2>/dev/null || true
    mkdir -p .beads
fi

# Memvid
if [ "$INSTALL_MEMVID" = true ]; then
    echo -e "${BLUE}[5/7] Memvid (long-term memory)${NC}"
    pip3 install memvid --quiet 2>/dev/null || pip3 install memvid
    mkdir -p .memvid
fi

# Claude-Mem
if [ "$INSTALL_CLAUDEMEM" = true ]; then
    echo -e "${BLUE}[6/7] Claude-Mem (session memory)${NC}"
    mkdir -p .claude-mem
    if command -v claude &> /dev/null; then
        echo "  Run: claude mcp add claude-mem -- npx -y @anthropic/claude-mem"
    fi
fi

# Unified MCP
echo -e "${BLUE}[7/7] Unified Memory MCP Server${NC}"
if ! pip3 install mcp httpx --quiet >/dev/null 2>&1; then
    echo "  Note: Install mcp/httpx manually (requires Python 3.10+)"
fi
mkdir -p .mcp
mkdir -p docs

# Download core files
echo ""
echo -e "${GREEN}Downloading configuration files...${NC}"

# Add cache-busting parameter to avoid GitHub CDN caching issues
CACHE_BUST="?$(date +%s)"
curl -fsSL "$REPO_RAW/src/unified_memory_mcp.py$CACHE_BUST" -o .mcp/unified_memory_mcp.py 2>/dev/null || echo "  Note: Download manually from $REPO_URL"
curl -fsSL "$REPO_RAW/src/session_hooks.py$CACHE_BUST" -o .mcp/session_hooks.py 2>/dev/null || true
curl -fsSL "$REPO_RAW/CLAUDE.md$CACHE_BUST" -o CLAUDE.md 2>/dev/null || echo "  Note: Download CLAUDE.md manually from $REPO_URL"

# Create .mcp.json if not exists
if [ ! -f ".mcp.json" ]; then
    cat > .mcp.json << 'EOF'
{
  "mcpServers": {
    "unified-memory": {
      "command": "python3",
      "args": [".mcp/unified_memory_mcp.py"],
      "env": {}
    },
    "beads": {
      "command": "beads-mcp",
      "args": [],
      "env": {}
    }
  }
}
EOF
    echo "  ✓ Created .mcp.json"
fi

# Update .gitignore
if [ -f ".gitignore" ]; then
    grep -q ".beads/beads.db" .gitignore 2>/dev/null || echo ".beads/beads.db" >> .gitignore
    grep -q ".claude-mem/" .gitignore 2>/dev/null || echo ".claude-mem/" >> .gitignore
    grep -q ".specstory/history/" .gitignore 2>/dev/null || echo "# .specstory/history/  # Uncomment to gitignore conversations" >> .gitignore
else
    cat > .gitignore << 'EOF'
# Unified Memory Stack
.beads/beads.db
.claude-mem/
# .specstory/history/  # Uncomment to gitignore conversations
EOF
fi

# -----------------------------------------------------------------------------
# Done!
# -----------------------------------------------------------------------------

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                    Installation Complete!                      ║${NC}"
echo -e "${GREEN}╠═══════════════════════════════════════════════════════════════╣${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║  Next steps:                                                   ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║  1. Initialize Beads:        bd init                           ║${NC}"
echo -e "${GREEN}║  2. Map codebase:            /cartographer (in Claude Code)    ║${NC}"
echo -e "${GREEN}║  3. Launch with history:     specstory run claude              ║${NC}"
echo -e "${GREEN}║  4. Discover MCP tools:      mcp-cli                           ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}║  Directory structure:                                          ║${NC}"
echo -e "${GREEN}║    .specstory/  - Conversation archive                         ║${NC}"
echo -e "${GREEN}║    .beads/      - Task graph                                   ║${NC}"
echo -e "${GREEN}║    .memvid/     - Long-term knowledge                          ║${NC}"
echo -e "${GREEN}║    .claude-mem/ - Session observations                         ║${NC}"
echo -e "${GREEN}║    .bmad/       - Orchestration config                         ║${NC}"
echo -e "${GREEN}║    .mcp/        - MCP servers                                  ║${NC}"
echo -e "${GREEN}║    CLAUDE.md    - Agent instructions                           ║${NC}"
echo -e "${GREEN}║                                                                ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Documentation: $REPO_URL"
echo ""

# -----------------------------------------------------------------------------
# BMAD (runs last due to interactive prompts)
# -----------------------------------------------------------------------------
if [ "$INSTALL_BMAD" = true ]; then
    echo -e "${BLUE}Installing BMAD (orchestration)...${NC}"
    echo -e "${YELLOW}Note: BMAD may prompt for input.${NC}"
    mkdir -p .bmad/agents
    if command -v npx &> /dev/null; then
        npx bmad-method@alpha install || echo "  Note: Run manually: npx bmad-method@alpha install"
    else
        echo "  Note: npx not found. Install Node.js, then run: npx bmad-method@alpha install"
    fi
fi
