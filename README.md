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
