#!/bin/bash
# SpeedsterAI — Launch Copilot CLI in the devcontainer
#
# Usage: ./copilot.sh [copilot args...]
#
# Starts a Copilot CLI session inside the devcontainer. The container
# must already be running (via `devcontainer up --workspace-folder .`).
#
# Authentication:
#   Create a fine-grained PAT with ONLY "Copilot Requests" permission:
#   https://github.com/settings/personal-access-tokens/new
#
#   Store in macOS Keychain:
#     security add-generic-password -a copilot -s speedster-ai-copilot -w "github_pat_..."
#
#   To update an existing token:
#     security delete-generic-password -a copilot -s speedster-ai-copilot
#     security add-generic-password -a copilot -s speedster-ai-copilot -w "github_pat_..."
#
#   The token has no access to repos, orgs, or other private data —
#   only Copilot API requests.
#
# Examples:
#   ./copilot.sh                    # Interactive session
#   ./copilot.sh --resume           # Resume last session
#   ./copilot.sh -p "run validate"  # Non-interactive prompt

set -e

WORKSPACE="$(cd "$(dirname "$0")" && pwd)"

# Retrieve token from macOS Keychain
COPILOT_TOKEN=$(security find-generic-password -a copilot -s speedster-ai-copilot -w 2>/dev/null) || true

if [ -z "$COPILOT_TOKEN" ]; then
    echo "Error: Copilot token not found in macOS Keychain." >&2
    echo "" >&2
    echo "Create a fine-grained PAT with only 'Copilot Requests' permission:" >&2
    echo "  https://github.com/settings/personal-access-tokens/new" >&2
    echo "" >&2
    echo "Then store it in Keychain:" >&2
    echo "  security add-generic-password -a copilot -s speedster-ai-copilot -w \"github_pat_...\"" >&2
    exit 1
fi

# Forward host git identity into the container
GIT_NAME=$(git config --global user.name 2>/dev/null || echo "")
GIT_EMAIL=$(git config --global user.email 2>/dev/null || echo "")

# Ensure container is running
if ! devcontainer exec --workspace-folder "$WORKSPACE" true 2>/dev/null; then
    echo "Starting devcontainer..."
    devcontainer up --workspace-folder "$WORKSPACE"
fi

# Configure git inside container
if [ -n "$GIT_NAME" ]; then
    devcontainer exec --workspace-folder "$WORKSPACE" git config --global user.name "$GIT_NAME"
fi
if [ -n "$GIT_EMAIL" ]; then
    devcontainer exec --workspace-folder "$WORKSPACE" git config --global user.email "$GIT_EMAIL"
fi

# Update Copilot CLI to latest version
echo "Checking for Copilot CLI updates..."
devcontainer exec --workspace-folder "$WORKSPACE" copilot update || true

# Launch Copilot CLI inside the container with the scoped token
devcontainer exec --workspace-folder "$WORKSPACE" \
    env GITHUB_TOKEN="$COPILOT_TOKEN" \
    copilot --allow-all-tools --allow-all-paths --allow-all-urls "$@"
