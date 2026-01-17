#!/bin/bash
set -e

# =============================================================================
# Unified Memory Stack Bootstrap
# Installs: Beads + Memvid + Claude-Mem + BMAD + Unified MCP Server
# =============================================================================

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║         Unified Memory Stack - Bootstrap Installer            ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Components:                                                  ║"
echo "║    • SpecStory    - Conversation history capture & search     ║"
echo "║    • mcp-cli      - Token-efficient MCP server CLI            ║"
echo "║    • Cartographer - Parallel codebase mapping                 ║"
echo "║    • Beads        - Task dependency graph (git-backed)        ║"
echo "║    • Memvid       - Long-term knowledge (.mv2 files)          ║"
echo "║    • Claude-Mem   - Session memory (observations)             ║"
echo "║    • BMAD         - Scale-adaptive orchestration              ║"
echo "║    • Unified MCP  - Integration layer                         ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# -----------------------------------------------------------------------------
# Detect OS
# -----------------------------------------------------------------------------
OS="$(uname -s)"
case "$OS" in
    Linux*)     PLATFORM=linux;;
    Darwin*)    PLATFORM=macos;;
    MINGW*|CYGWIN*|MSYS*) PLATFORM=windows;;
    *)          PLATFORM=unknown;;
esac

echo "Detected platform: $PLATFORM"
echo ""

# -----------------------------------------------------------------------------
# Check prerequisites
# -----------------------------------------------------------------------------
echo "Checking prerequisites..."

check_command() {
    if command -v "$1" &> /dev/null; then
        echo "  ✓ $1 found"
        return 0
    else
        echo "  ✗ $1 not found"
        return 1
    fi
}

MISSING=()
check_command git || MISSING+=("git")
check_command python3 || MISSING+=("python3")
check_command pip3 || MISSING+=("pip3")

if [ ${#MISSING[@]} -ne 0 ]; then
    echo ""
    echo "Error: Missing required tools: ${MISSING[*]}"
    echo "Please install them and re-run this script."
    exit 1
fi

echo ""

# -----------------------------------------------------------------------------
# Install SpecStory (conversation history capture)
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing SpecStory (conversation history capture)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v specstory &> /dev/null; then
    echo "  SpecStory already installed: $(specstory --version 2>/dev/null || echo 'unknown version')"
else
    if command -v brew &> /dev/null; then
        echo "  Installing via Homebrew..."
        brew tap specstoryai/tap 2>/dev/null
        brew install specstory
    else
        echo "  Installing via curl..."
        curl -fsSL https://raw.githubusercontent.com/specstoryai/getspecstory/main/install.sh | bash
    fi
fi

echo "  ✓ SpecStory ready (use 'specstory run claude' to launch with history)"
echo ""

# -----------------------------------------------------------------------------
# Install mcp-cli (token-efficient MCP access)
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing mcp-cli (token-efficient MCP access)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v mcp-cli &> /dev/null; then
    echo "  mcp-cli already installed: $(mcp-cli --version 2>/dev/null || echo 'unknown version')"
else
    if command -v bun &> /dev/null; then
        echo "  Installing via bun..."
        bun install -g https://github.com/philschmid/mcp-cli
    else
        echo "  Installing via curl..."
        curl -fsSL https://raw.githubusercontent.com/philschmid/mcp-cli/main/install.sh | bash
    fi
fi

echo "  ✓ mcp-cli ready (use 'mcp-cli' to discover MCP tools)"
echo ""

# -----------------------------------------------------------------------------
# Install Cartographer
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Cartographer (parallel codebase mapping)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Install tiktoken dependency
pip3 install tiktoken --quiet 2>/dev/null || pip3 install tiktoken

# Add Cartographer marketplace and install plugin
if command -v claude &> /dev/null; then
    echo "  Adding Cartographer marketplace..."
    claude /plugin marketplace add kingbootoshi/cartographer 2>/dev/null || {
        echo "  Note: Run in Claude Code: /plugin marketplace add kingbootoshi/cartographer"
    }
    echo "  Installing Cartographer plugin..."
    claude /plugin install cartographer 2>/dev/null || {
        echo "  Note: Run in Claude Code: /plugin install cartographer"
    }
else
    echo "  Note: Claude Code not found. Install Cartographer manually:"
    echo "    /plugin marketplace add kingbootoshi/cartographer"
    echo "    /plugin install cartographer"
fi

echo "  ✓ Cartographer ready (run /cartographer to map codebase)"
echo ""

# -----------------------------------------------------------------------------
# Install Beads
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Beads (task dependency graph)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v bd &> /dev/null; then
    echo "  Beads already installed: $(bd --version 2>/dev/null || echo 'unknown version')"
else
    if [ "$PLATFORM" = "macos" ] || [ "$PLATFORM" = "linux" ]; then
        curl -fsSL https://raw.githubusercontent.com/steveyegge/beads/main/scripts/install.sh | bash
    else
        echo "  Please install Beads manually from: https://github.com/steveyegge/beads"
    fi
fi

# Install Beads MCP
echo "  Installing Beads MCP server..."
pip3 install beads-mcp --quiet 2>/dev/null || pip3 install beads-mcp

echo ""

# -----------------------------------------------------------------------------
# Install Memvid
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Memvid (long-term knowledge)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip3 install memvid --quiet 2>/dev/null || pip3 install memvid

echo "  ✓ Memvid installed"
echo ""

# -----------------------------------------------------------------------------
# Install Claude-Mem
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Claude-Mem (session memory)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Claude-Mem is a Claude Code plugin
if command -v claude &> /dev/null; then
    echo "  Installing via Claude Code plugin marketplace..."
    claude mcp add claude-mem -- npx -y @anthropic/claude-mem 2>/dev/null || {
        echo "  Note: Install manually with: claude mcp add claude-mem"
    }
else
    echo "  Note: Claude Code not found. Install Claude-Mem manually when available."
fi

echo ""

# -----------------------------------------------------------------------------
# Install BMAD
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing BMAD (scale-adaptive orchestration)..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if command -v npx &> /dev/null; then
    npx bmad-method@alpha install 2>/dev/null || {
        echo "  Note: BMAD install may require manual setup"
        echo "  Run: npx bmad-method@alpha install"
    }
else
    echo "  Note: npx not found. Install Node.js, then run: npx bmad-method@alpha install"
fi

echo ""

# -----------------------------------------------------------------------------
# Install Unified Memory MCP dependencies
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Installing Unified Memory MCP dependencies..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip3 install mcp httpx --quiet 2>/dev/null || pip3 install mcp httpx

echo "  ✓ MCP dependencies installed"
echo ""

# -----------------------------------------------------------------------------
# Initialize project structure
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Initializing project structure..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create directory structure
mkdir -p docs
mkdir -p .specstory/history
mkdir -p .beads
mkdir -p .memvid
mkdir -p .claude-mem
mkdir -p .bmad/agents

# Initialize Beads if not already done
if [ ! -f ".beads/beads.jsonl" ]; then
    if command -v bd &> /dev/null; then
        bd init 2>/dev/null || echo "  Note: Run 'bd init' manually to initialize Beads"
    fi
fi

# Create empty Memvid store placeholder
if [ ! -f ".memvid/knowledge.mv2" ]; then
    touch .memvid/.gitkeep
    echo "  Created .memvid/ directory (initialize with first append)"
fi

# Add to .gitignore
if [ -f ".gitignore" ]; then
    grep -q ".beads/beads.db" .gitignore || echo ".beads/beads.db" >> .gitignore
    grep -q ".claude-mem/" .gitignore || echo ".claude-mem/" >> .gitignore
else
    cat > .gitignore << 'EOF'
# Unified Memory Stack
.beads/beads.db
.claude-mem/
EOF
fi

echo "  ✓ Directory structure created"
echo ""

# -----------------------------------------------------------------------------
# Create MCP configuration
# -----------------------------------------------------------------------------
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Creating MCP configuration..."
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create .mcp.json if it doesn't exist
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
else
    echo "  .mcp.json already exists - please add unified-memory server manually"
fi

# Copy unified memory MCP server
mkdir -p .mcp
if [ -f "src/unified_memory_mcp.py" ]; then
    cp src/unified_memory_mcp.py .mcp/
    echo "  ✓ Copied unified_memory_mcp.py to .mcp/"
fi

echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    Installation Complete!                      ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║  Next steps:                                                   ║"
echo "║                                                                ║"
echo "║  1. Copy CLAUDE.md to your project root                        ║"
echo "║  2. Restart Claude Code to load MCP servers                    ║"
echo "║  3. Run /cartographer to map your codebase                     ║"
echo "║  4. Run: bd init                                               ║"
echo "║  5. Launch with: specstory run claude                          ║"
echo "║                                                                ║"
echo "║  Directory structure created:                                  ║"
echo "║    .specstory/  - Conversation history (searchable archive)    ║"
echo "║    docs/        - Codebase map (Cartographer)                  ║"
echo "║    .beads/      - Task graph (git-tracked)                     ║"
echo "║    .memvid/     - Long-term knowledge                          ║"
echo "║    .claude-mem/ - Session observations                         ║"
echo "║    .bmad/       - Orchestration config                         ║"
echo "║    .mcp/        - MCP server scripts                           ║"
echo "║                                                                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
