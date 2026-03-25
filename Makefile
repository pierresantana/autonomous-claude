IMAGE_NAME := autonomous-claude

# Load .env if it exists
-include .env
export

# REPO_PATH can be overridden on the command line: make run REPO_PATH=/other/path
REPO_PATH ?=
CLAUDE_PROMPT ?=
CLAUDE_COMMAND ?=

.PHONY: build run shell clean help

help:
	@echo "Usage:"
	@echo "  make build                                   Build the Docker image"
	@echo "  make run                                     Run using values from .env"
	@echo "  make run CLAUDE_PROMPT='fix the auth bug'    Run Claude with a prompt"
	@echo "  make run CLAUDE_COMMAND='./scripts/run.sh'   Run a shell command directly"
	@echo "  make shell                                   Open a bash shell in the container"
	@echo "  make clean                                   Remove the Docker image"

build:
	docker build -t $(IMAGE_NAME) .

run:
	@[ -n "$(REPO_PATH)" ] || (echo "ERROR: REPO_PATH is not set. Add it to .env or pass as argument." && exit 1)
	@{ [ -n "$(CLAUDE_PROMPT)" ] || [ -n "$(CLAUDE_COMMAND)" ]; } || \
		(echo "ERROR: CLAUDE_PROMPT or CLAUDE_COMMAND must be set." && exit 1)
	$(eval CID := $(shell docker run -d --rm \
		-e CLAUDE_CODE_OAUTH_TOKEN=$(CLAUDE_CODE_OAUTH_TOKEN) \
		-e CLAUDE_PROMPT="$(CLAUDE_PROMPT)" \
		-e CLAUDE_COMMAND="$(CLAUDE_COMMAND)" \
		-v "$(REPO_PATH):/workspace" \
		$(IMAGE_NAME)))
	@echo "==> Container: $(CID)"
	@docker logs -f $(CID)

shell:
	@[ -n "$(REPO_PATH)" ] || (echo "ERROR: REPO_PATH is not set. Add it to .env or pass as argument." && exit 1)
	docker run --rm -it \
		-e CLAUDE_CODE_OAUTH_TOKEN=$(CLAUDE_CODE_OAUTH_TOKEN) \
		-v "$(REPO_PATH):/workspace" \
		--entrypoint bash \
		$(IMAGE_NAME)

clean:
	docker rmi $(IMAGE_NAME)
