# gacp - Smart Git Workflow Automation

A powerful Oh My Zsh function that combines `git add`, `commit`, and `push` with optional AI-powered commit messages via Ollama.

## Quick Start

```bash
# Install
cp git-functions.zsh ~/.oh-my-zsh/custom/
source ~/.zshrc

# Use
gacp "fix: resolve bug"              # Manual commit
gacp -ai                              # AI-generated commit
gacp --help                           # Show help
```

## Features

✅ **One Command** - Add, commit, and push in a single step
🤖 **AI Commits** - Generate intelligent commit messages using Ollama
🎯 **Smart Filtering** - Excludes irrelevant files from AI analysis
📝 **Conventional Commits** - Follows industry-standard format
🚀 **Branch Aware** - Works with any branch, defaults to current

## Installation

### Basic Setup
1. Copy `git-functions.zsh` to `~/.oh-my-zsh/custom/`
2. Restart shell or run `source ~/.zshrc`

### For AI Mode
```bash
# Install Ollama
brew install ollama  # macOS
# Or visit: https://ollama.ai

# Install model
ollama pull qwen2.5-coder

# Install jq
brew install jq
```

## Usage

### Manual Commits
```bash
gacp "feat: add user authentication"
gacp "fix: memory leak in service" develop
```

### AI-Powered Commits
```bash
gacp -ai                    # Current branch
gacp -ai main              # Specific branch
```

### How AI Mode Works
1. Stages all changes
2. Analyzes diff (excludes irrelevant files)
3. Generates conventional commit message
4. Shows message for approval
5. Commits and pushes on confirmation

### Files Excluded from AI Analysis
- Dependencies: `node_modules/`, `vendor/`
- Lock files: `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- Build artifacts: `dist/`, `build/`, `.next/`
- Cache: `.cache/`, `coverage/`, `__pycache__/`
- Assets: `*.svg`
- Config: `.env.local`, `.DS_Store`

## Examples

### Daily Workflow
```bash
# Quick fixes
gacp "fix: typo in error message"

# Feature development
git checkout -b feature/payments
# ... make changes ...
gacp -ai

# Hotfix to main
gacp "hotfix: security patch" main
```

### AI Workflow Example
```bash
$ gacp -ai
🤖 Analyzing changes and generating commit message...

📝 Proposed commit message:
   "refactor: optimize database queries for better performance"

Accept this message? (y/n): y
✅ Changes committed and pushed!
```

## Troubleshooting

### Command Not Found
```bash
ls ~/.oh-my-zsh/custom/git-functions.zsh
source ~/.zshrc
```

### AI Mode Not Working
```bash
# Check Ollama
ollama serve           # Start server
ollama list           # Verify model
curl http://localhost:11434/api/tags  # Test API

# Check dependencies
which jq
```

### Git Issues
```bash
# Not in repository
git init

# No remote
git remote add origin <url>

# Authentication
git config credential.helper cache
```

## Configuration

### AI Settings
- **Model**: qwen2.5-coder:latest
- **Temperature**: 0.7
- **Max diff lines**: 200
- **API**: http://localhost:11434

### Commit Format
AI generates conventional commits:
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Code restructuring
- `test:` Testing
- `chore:` Maintenance

## Tips

1. **Review AI commits** - Always check generated messages
2. **Stage selectively** - Use `git add -p` for partial staging
3. **Branch naming** - Use `feature/`, `fix/`, `hotfix/` prefixes
4. **Small commits** - Keep changes focused and atomic

## License

Free to use and modify for Oh My Zsh users.