#!/usr/bin/env bash
set -euo pipefail

# Install Feynman (self-contained binary, no system deps needed)
curl -fsSL https://feynman.is/install | bash
export PATH="$HOME/.local/bin:$PATH"

# Materialize Feynman config from templates + env vars
mkdir -p "$HOME/.feynman/agent"

envsubst < .routine/agent.settings.template.json > "$HOME/.feynman/agent/settings.json"
envsubst < .routine/web-search.template.json > "$HOME/.feynman/web-search.json"

# ANTHROPIC_API_KEY is read directly from the environment by Feynman —
# no auth.json needed when the env var is present.

# Smoke tests
feynman --version
feynman status
pandoc --version | head -1   # required for HTML rendering step
