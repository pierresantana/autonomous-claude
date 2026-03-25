# autonomous-claude

Debian-based Docker container that runs Claude Code autonomously on a local git repository.

## Requirements

- Docker
- A Claude Code OAuth token (`CLAUDE_CODE_OAUTH_TOKEN`)

## Setup

```bash
cp .env.example .env
# edit .env with your values
```

**.env fields:**

| Variable | Required | Description |
|---|---|---|
| `CLAUDE_CODE_OAUTH_TOKEN` | yes | Claude Code OAuth token |
| `REPO_PATH` | yes | Absolute path to the local git repository |
| `CLAUDE_PROMPT` | one of | Natural language task for Claude to execute |
| `CLAUDE_COMMAND` | one of | Shell command to run directly inside the container |
| `GIT_USER_NAME` | no | Git `user.name` for commits made inside the container |
| `GIT_USER_EMAIL` | no | Git `user.email` for commits made inside the container |
| `CLAUDE_CONFIG_DIR` | no | Host path mounted to `/home/claude/.claude` (defaults to `~/.claude`) |

## Usage

```bash
# Build the image
make build

# Run using .env values
make run

# Override prompt on the command line
make run CLAUDE_PROMPT="refactor the auth module to use JWT"

# Run a shell command directly (bypasses Claude)
make run CLAUDE_COMMAND="./scripts/run.sh"

# Open an interactive shell for debugging
make shell

# Remove the image
make clean
```

## How it works

- The local repository is mounted at `/workspace` inside the container.
- If `CLAUDE_PROMPT` is set, Claude Code runs in fully autonomous mode (`--dangerously-skip-permissions`) with streaming output.
- If `CLAUDE_COMMAND` is set, the command is executed directly via `bash` — Claude is not invoked.
- `make run` starts the container in detached mode, then follows its logs in real time.
- When `GIT_USER_NAME` / `GIT_USER_EMAIL` are set, they are applied via `git config --global` at startup so commits are correctly attributed.
- `CLAUDE_CONFIG_DIR` (default `~/.claude`) is mounted read-only at `/home/claude/.claude`, allowing the container to reuse your local Claude Code configuration and memory.
