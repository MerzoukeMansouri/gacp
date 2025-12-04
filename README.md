# gacp - Git Add, Commit & Push Function for Oh My Zsh

A powerful git helper function for Oh My Zsh that streamlines your git workflow by combining `git add`, `commit`, and `push` operations with optional AI-powered commit message generation.

## Installation

1. Place `git-functions.zsh` in your Oh My Zsh custom directory:
   ```bash
   ~/.oh-my-zsh/custom/git-functions.zsh
   ```

2. Restart your shell or reload configuration:
   ```bash
   source ~/.zshrc
   ```

3. The `gacp` function will be automatically available in all new shell sessions.

## Prerequisites

### Basic Usage
- Git installed and configured
- An active git repository

### AI Mode Requirements
- [Ollama](https://ollama.ai/) installed and running locally
- `qwen2.5-coder:latest` model installed:
  ```bash
  ollama pull qwen2.5-coder
  ```
- `jq` for JSON processing:
  ```bash
  # macOS
  brew install jq

  # Ubuntu/Debian
  sudo apt-get install jq

  # Other systems
  # Visit: https://stedolan.github.io/jq/download/
  ```
- `curl` for API calls (usually pre-installed)

## Usage

### Quick Help
```bash
gacp --help
# or
gacp -h
```

### Manual Commit Mode
```bash
# Commit with manual message to current branch
gacp "your commit message"

# Commit with manual message to specific branch
gacp "your commit message" branch-name
```

### AI-Powered Commit Mode
```bash
# Generate AI commit message for current branch
gacp -ai

# Generate AI commit message for specific branch
gacp -ai branch-name
```

## Features

### Core Functionality
- **Single Command Operation**: Combines `git add .`, `git commit`, and `git push` into one command
- **Branch Flexibility**: Works with current branch by default or specified branch
- **Error Handling**: Comprehensive error messages and validation
- **Built-in Help**: Access documentation directly from the command line with `--help`

### AI Mode Capabilities
- **Intelligent Analysis**: Examines staged changes to understand code modifications
- **Conventional Commits**: Generates messages following the conventional commits format (feat, fix, refactor, etc.)
- **Smart Filtering**: Automatically excludes irrelevant files from analysis
- **Interactive Confirmation**: Shows proposed commit message for approval before committing
- **Performance Optimized**: Limits diff analysis to 200 lines for quick response

### Excluded Files in AI Analysis
The AI mode intelligently filters out:
- `node_modules/`, `vendor/` directories
- Lock files (`package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`, `bun.lockb`)
- Build outputs (`dist/`, `build/`, `.next/`)
- Cache directories (`.cache/`, `coverage/`)
- System files (`.DS_Store`, `thumbs.db`)
- Python cache (`__pycache__/`, `*.pyc`)
- Environment files (`.env.local`, `.env.*.local`)

## Examples

### Basic Workflow
```bash
# Make your code changes
vim src/app.js

# Commit and push with manual message
gacp "fix: resolve null pointer exception in user service"
```

### Feature Development
```bash
# Develop new feature
vim src/features/auth.js

# Commit to feature branch
gacp "feat: implement JWT authentication" feature/auth
```

### AI-Assisted Commits
```bash
# Make complex changes
vim src/api/handlers.js
vim src/api/validators.js
vim tests/api.test.js

# Let AI analyze and generate commit message
gacp -ai

# Output:
# 🤖 Analyzing changes and generating commit message...
#
# 📝 Proposed commit message:
#    "refactor: restructure API handlers with improved validation"
#
# Accept this message? (y/n): y
```

### Working with Branches
```bash
# Quick fix on main branch
gacp "hotfix: critical security patch" main

# Feature work on develop
gacp "feat: add user preferences API" develop

# AI commit to specific branch
gacp -ai staging
```

## How AI Mode Works

1. **Stage Changes**: Runs `git add .` to stage all modifications
2. **Analyze Diff**: Captures staged changes using `git diff --cached`
3. **Filter Content**: Excludes irrelevant files to focus on meaningful changes
4. **Generate Message**: Sends diff to Ollama API with qwen2.5-coder model
5. **Prompt Confirmation**: Displays proposed message for user approval
6. **Execute Operations**: On approval, commits and pushes changes

### AI Configuration
- **Model**: qwen2.5-coder:latest
- **API Endpoint**: http://localhost:11434/api/generate
- **Temperature**: 0.7 (balanced creativity/consistency)
- **Max Tokens**: 100 (concise messages)
- **Format**: Conventional commits (type: description)

## Troubleshooting

### Command Not Found
```bash
# Ensure file is in correct location
ls -la ~/.oh-my-zsh/custom/git-functions.zsh

# Reload shell configuration
source ~/.zshrc
```

### AI Mode Issues

#### Ollama Not Running
```bash
# Start Ollama service
ollama serve

# Verify it's running
curl http://localhost:11434/api/tags
```

#### Model Not Installed
```bash
# Check installed models
ollama list

# Install required model
ollama pull qwen2.5-coder
```

#### JSON Processing Error
```bash
# Verify jq installation
which jq

# Install if missing
brew install jq  # macOS
```

### Git Errors

#### Not in Git Repository
```bash
# Initialize git repository
git init

# Or verify you're in correct directory
pwd
git status
```

#### No Remote Branch
```bash
# Add remote origin
git remote add origin <repository-url>

# Create and push to new branch
git checkout -b new-branch
gacp "initial commit"
```

#### Authentication Failed
```bash
# Configure git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# For HTTPS, cache credentials
git config --global credential.helper cache

# For SSH, ensure keys are configured
ssh-add ~/.ssh/id_rsa
```

## Best Practices

### Commit Messages
- **Manual Mode**: Write clear, descriptive messages following your team's conventions
- **AI Mode**: Review generated messages carefully before accepting
- **Format**: Consider using conventional commits format (feat, fix, docs, style, refactor, test, chore)

### AI Usage Tips
1. **Review Changes First**: Run `git diff` before using AI mode to understand what will be analyzed
2. **Chunk Large Changes**: Break big features into smaller, logical commits
3. **Edit When Needed**: Don't hesitate to decline AI suggestions and write your own
4. **Keep Diff Focused**: Stage only related changes for better AI analysis

### Branch Strategy
- Use descriptive branch names (feature/, bugfix/, hotfix/)
- Specify branch explicitly when working on multiple branches
- Always verify current branch with `git branch --show-current`

## Workflow Integration

### Daily Development
```bash
# Morning sync
git pull origin main

# Work on feature
# ... make changes ...

# Quick commit with AI
gacp -ai

# Or specific message
gacp "feat: complete user story #123"
```

### Code Review Process
```bash
# Create feature branch
git checkout -b feature/new-widget

# Develop and commit
gacp "feat: add widget component structure"
# ... more changes ...
gacp "style: improve widget responsive design"
# ... test additions ...
gacp "test: add widget unit tests"

# Final push before PR
gacp -ai feature/new-widget
```

### Hotfix Workflow
```bash
# Switch to main
git checkout main
git pull origin main

# Create hotfix branch
git checkout -b hotfix/security-issue

# Fix and commit
gacp "fix: patch XSS vulnerability in input handler"

# Push to main
git checkout main
git merge hotfix/security-issue
gacp "merge: hotfix for security issue" main
```

## Exit Codes

- `0` - Success: All operations completed successfully
- `1` - Error: Various failure conditions including:
  - Not in a git repository
  - No changes to commit
  - Commit or push failed
  - AI generation failed
  - User declined AI suggestion

## Contributing

Feel free to modify the function to suit your workflow. Some ideas for enhancement:
- Add support for different AI models
- Implement commit message templates
- Add pre-commit hooks integration
- Support for signed commits
- Custom exclusion patterns

## License

This function is provided as-is for use with Oh My Zsh. Feel free to modify and share!

## Support

For issues or questions:
1. Run `gacp --help` for built-in documentation
2. Check Ollama status: `ollama list`
3. Verify git configuration: `git config --list`
4. Review shell configuration: `echo $ZSH_CUSTOM`