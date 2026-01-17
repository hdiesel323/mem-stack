# Contributing to Unified Memory Stack

Thanks for your interest in contributing! This project integrates 8 different systems, so there are many ways to help.

## Quick Start for Contributors

```bash
# Fork and clone
git clone https://github.com/hdiesel323/mem-stack
cd mem-stack

# Create a branch
git checkout -b feature/your-feature-name

# Make changes, test locally
./bootstrap.sh

# Commit with conventional commits
git commit -m "feat(beads): add automatic priority inference"

# Push and create PR
git push origin feature/your-feature-name
```

## Areas We Need Help

### High Priority

1. **SpecStory → Memvid Pipeline**
   - Extract learnings from `.specstory/history/` conversations
   - Summarize and persist to Memvid automatically
   - Deduplication of similar learnings

2. **mcp-cli Integration**
   - Dynamic tool discovery in CLAUDE.md
   - Shell scripts for common workflows

3. **Testing Suite**
   - Unit tests for `unified_memory_mcp.py`
   - Integration tests for component communication

### Medium Priority

4. **BMAD Deep Integration**
   - Actually invoke BMAD agents based on complexity
   - Agent selection heuristics

5. **Cross-Project Memory**
   - Federation across multiple repos
   - Shared team knowledge base

6. **Web UI**
   - Browse Memvid knowledge
   - Visualize Beads task graph
   - Search SpecStory archive

### Documentation

- Tutorials for each component
- Video walkthroughs
- Architecture deep-dives

## Code Style

- Python: Black formatter, type hints
- Shell: ShellCheck compliant
- Markdown: Consistent headers, code blocks

## Commit Messages

We use [Conventional Commits](https://www.conventionalcommits.org/):

```
feat(component): add new feature
fix(beads): resolve sync issue
docs: update README
chore: update dependencies
```

Components: `specstory`, `mcp-cli`, `cartographer`, `beads`, `memvid`, `claude-mem`, `bmad`, `unified-mcp`, `bootstrap`

## Testing Your Changes

```bash
# Test bootstrap on clean system (use Docker)
docker run -it --rm -v $(pwd):/app ubuntu:22.04 bash
cd /app
apt update && apt install -y curl git python3 python3-pip
./bootstrap.sh

# Test in actual project
cd /path/to/test-project
/path/to/mem-stack/bootstrap.sh
```

## Pull Request Process

1. Update README.md if adding new features
2. Update CLAUDE.md if changing agent behavior
3. Test bootstrap.sh on fresh system
4. Request review from maintainers

## Questions?

- Open a [Discussion](https://github.com/hdiesel323/mem-stack/discussions)
- Tag issues with `question` label

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
