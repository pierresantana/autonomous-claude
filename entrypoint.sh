#!/bin/bash
set -e

# Validate required env vars
if [ -z "$CLAUDE_CODE_OAUTH_TOKEN" ]; then
    echo "ERROR: CLAUDE_CODE_OAUTH_TOKEN is not set."
    exit 1
fi

if [ -z "$CLAUDE_PROMPT" ] && [ -z "$CLAUDE_COMMAND" ]; then
    echo "ERROR: CLAUDE_PROMPT or CLAUDE_COMMAND must be set."
    exit 1
fi

# Verify mounted workspace is a git repo
if [ ! -d "/workspace/.git" ]; then
    echo "WARNING: /workspace does not appear to be a git repository."
fi

# Configure git identity if provided
if [ -n "$GIT_USER_NAME" ]; then
    git config --global user.name "$GIT_USER_NAME"
fi
if [ -n "$GIT_USER_EMAIL" ]; then
    git config --global user.email "$GIT_USER_EMAIL"
fi

echo "==> Working directory: /workspace"

# If CLAUDE_COMMAND is set, run it directly (bypasses Claude)
if [ -n "$CLAUDE_COMMAND" ]; then
    echo "==> Command: $CLAUDE_COMMAND"
    echo ""
    exec bash -c "$CLAUDE_COMMAND"
fi

# Otherwise, run Claude with the prompt
echo "==> Prompt: $CLAUDE_PROMPT"
echo ""

claude \
    --dangerously-skip-permissions \
    --output-format stream-json \
    -p "$CLAUDE_PROMPT" \
    | while IFS= read -r line; do
        echo "$line" | python3 -c "
import sys, json
try:
    obj = json.loads(sys.stdin.read())
    t = obj.get('type','')
    if t == 'assistant':
        for block in obj.get('message',{}).get('content',[]):
            if block.get('type') == 'text':
                print(block['text'], end='', flush=True)
    elif t == 'result':
        print('\n\n[done] ' + obj.get('subtype',''))
except:
    pass
" 2>/dev/null || true
    done
