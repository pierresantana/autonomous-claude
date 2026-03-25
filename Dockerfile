FROM debian:bookworm-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    git \
    ca-certificates \
    gnupg \
    python3 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user that will run Claude
RUN useradd -m -s /bin/bash claude \
    && echo 'claude ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/claude

# Install Claude Code as that user
USER claude
RUN curl -fsSL https://claude.ai/install.sh | bash

ENV PATH="/home/claude/.local/bin:${PATH}"

# Back to root for system-level config
USER root

RUN git config --system --add safe.directory /workspace

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /workspace

USER claude

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
