# Git add, commit, and push in one command
# Usage: gacp "commit message" [branch-name]  (branch optional, defaults to current)
#        gacp -ai [branch-name]  (AI-generated commit message, branch optional)
gacp() {
  # Check for help flag
  if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "gacp - Git Add, Commit, and Push in one command"
    echo ""
    echo "USAGE:"
    echo "  gacp [OPTIONS] <commit-message> [branch-name]"
    echo "  gacp -ai [branch-name]"
    echo "  gacp --help"
    echo ""
    echo "DESCRIPTION:"
    echo "  Combines git add, commit, and push operations into a single command."
    echo "  Supports manual commit messages or AI-generated messages using Ollama."
    echo ""
    echo "OPTIONS:"
    echo "  -ai              Use AI to generate commit message based on staged changes"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "ARGUMENTS:"
    echo "  commit-message   The commit message (required unless using -ai)"
    echo "  branch-name      Target branch (optional, defaults to current branch)"
    echo ""
    echo "EXAMPLES:"
    echo "  # Manual commit message"
    echo "  gacp \"fix: resolve authentication bug\""
    echo ""
    echo "  # Manual commit to specific branch"
    echo "  gacp \"feat: add user profile\" develop"
    echo ""
    echo "  # AI-generated commit message"
    echo "  gacp -ai"
    echo ""
    echo "  # AI commit to specific branch"
    echo "  gacp -ai main"
    echo ""
    echo "REQUIREMENTS FOR AI MODE:"
    echo "  - Ollama running locally (http://localhost:11434)"
    echo "  - qwen2.5-coder model installed (ollama pull qwen2.5-coder)"
    echo "  - jq installed for JSON processing"
    echo ""
    echo "AI MODE FEATURES:"
    echo "  - Analyzes git diff to understand changes"
    echo "  - Generates conventional commit format messages"
    echo "  - Excludes irrelevant files (node_modules, lock files, etc.)"
    echo "  - Shows proposed message for confirmation"
    echo "  - Limits diff analysis to 200 lines for performance"
    echo ""
    echo "EXCLUDED FILES IN AI ANALYSIS:"
    echo "  - node_modules/, vendor/"
    echo "  - Lock files (package-lock.json, yarn.lock, etc.)"
    echo "  - Build outputs (dist/, build/, .next/)"
    echo "  - Cache directories (.cache/, coverage/)"
    echo "  - System files (.DS_Store, thumbs.db)"
    echo "  - Python cache (__pycache__, *.pyc)"
    echo "  - Environment files (.env.local, .env.*.local)"
    echo ""
    echo "EXIT CODES:"
    echo "  0    Success"
    echo "  1    Error (not in git repo, no changes, commit failed, etc.)"
    return 0
  fi

  local ai_mode=false
  local commit_msg=""
  local branch=""

  # Parse arguments
  if [ "$1" = "-ai" ]; then
    ai_mode=true
    # If branch provided, use it; otherwise use current branch
    if [ -n "$2" ]; then
      branch="$2"
    else
      branch=$(git branch --show-current 2>/dev/null)
      if [ -z "$branch" ]; then
        echo "❌ Not in a git repository or no current branch"
        return 1
      fi
    fi
  else
    if [ -z "$1" ]; then
      echo "Usage: gacp \"<commit-message>\" [branch-name]"
      echo "       gacp -ai [branch-name]"
      echo "       gacp --help"
      echo ""
      echo "Run 'gacp --help' for more information"
      return 1
    fi
    commit_msg="$1"
    # If branch provided, use it; otherwise use current branch
    if [ -n "$2" ]; then
      branch="$2"
    else
      branch=$(git branch --show-current 2>/dev/null)
      if [ -z "$branch" ]; then
        echo "❌ Not in a git repository or no current branch"
        return 1
      fi
    fi
  fi

  # Add all changes
  git add . || return 1

  # AI mode: generate commit message using local Ollama
  if [ "$ai_mode" = true ]; then
    echo "🤖 Analyzing changes and generating commit message..."

    # Get the diff (first 200 lines), excluding non-relevant files
    local diff_output=$(git diff --cached -- . \
      ':(exclude)node_modules' \
      ':(exclude)package-lock.json' \
      ':(exclude)yarn.lock' \
      ':(exclude)pnpm-lock.yaml' \
      ':(exclude)bun.lockb' \
      ':(exclude).next' \
      ':(exclude)dist' \
      ':(exclude)build' \
      ':(exclude)coverage' \
      ':(exclude).cache' \
      ':(exclude)vendor' \
      ':(exclude)__pycache__' \
      ':(exclude)*.pyc' \
      ':(exclude).DS_Store' \
      ':(exclude)thumbs.db' \
      ':(exclude).env.local' \
      ':(exclude).env.*.local' \
      | head -n 200)

    if [ -z "$diff_output" ]; then
      echo "❌ No staged changes found"
      return 1
    fi

    # Build the prompt
    local prompt="Based on the following git diff, generate a concise commit message following conventional commits format (type: description). Use types like feat, fix, refactor, docs, style, test, chore. Keep it under 72 characters. Only output the commit message, nothing else.\n\nDiff:\n${diff_output}"

    # Build the JSON payload for Ollama
    local json_payload=$(jq -n \
      --arg prompt "$prompt" \
      '{
        "model": "qwen2.5-coder:latest",
        "prompt": $prompt,
        "stream": false,
        "options": {
          "temperature": 0.7,
          "num_predict": 100
        }
      }')

    # Call Ollama API
    local api_response=$(curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d "$json_payload")

    # Extract commit message from response
    commit_msg=$(echo "$api_response" | jq -r '.response' 2>/dev/null | tr -d '\n')

    if [ -z "$commit_msg" ] || [ "$commit_msg" = "null" ]; then
      echo "❌ Failed to generate commit message"
      echo "API Response: $api_response"
      return 1
    fi

    # Show the proposed commit message
    echo ""
    echo "📝 Proposed commit message:"
    echo "   \"$commit_msg\""
    echo ""
    echo -n "Accept this message? (y/n): "
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
      echo "❌ Commit cancelled"
      git reset > /dev/null 2>&1
      return 1
    fi
  fi

  # Commit and push
  git commit -m "$commit_msg" && \
  git push origin "$branch"
}
