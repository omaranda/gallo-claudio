#!/usr/bin/env bash
# =============================================================================
# install.sh — gallo-claudio plugin installer for Claude Code
# Usage: ./install.sh [--uninstall]
#
# Registers this directory as a local marketplace, then installs the plugin
# using the official Claude Code CLI commands.
#
# Requires: claude (Claude Code CLI) installed and available in PATH.
# =============================================================================
set -euo pipefail

MARKETPLACE_NAME="gallo-claudio-local"
PLUGIN_NAME="gallo-claudio@${MARKETPLACE_NAME}"
INSTALL_PATH="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[gallo-claudio]${NC} $*"; }
warn() { echo -e "${YELLOW}[gallo-claudio]${NC} $*"; }
err()  { echo -e "${RED}[gallo-claudio]${NC} $*" >&2; }

# --- dependency check ---
if ! command -v claude &>/dev/null; then
  err "Claude Code CLI is required but not found in PATH."
  echo "  Install: https://claude.ai/claude-code"
  exit 1
fi

# --- uninstall ---
if [[ "${1:-}" == "--uninstall" ]]; then
  log "Uninstalling ${PLUGIN_NAME}..."

  claude plugins uninstall "${PLUGIN_NAME}" 2>/dev/null && \
    log "Plugin uninstalled" || \
    warn "Plugin was not installed (or already removed)"

  claude plugins marketplace remove "${MARKETPLACE_NAME}" 2>/dev/null && \
    log "Marketplace removed" || \
    warn "Marketplace was not registered (or already removed)"

  # Clean up legacy entries if they exist (from old install.sh)
  PLUGINS_FILE="${HOME}/.claude/plugins/installed_plugins.json"
  if [[ -f "$PLUGINS_FILE" ]] && command -v jq &>/dev/null; then
    if jq -e '.plugins["gallo-claudio@local"]' "$PLUGINS_FILE" &>/dev/null; then
      jq 'del(.plugins["gallo-claudio@local"])' "$PLUGINS_FILE" > "${PLUGINS_FILE}.tmp" \
        && mv "${PLUGINS_FILE}.tmp" "$PLUGINS_FILE"
      log "Cleaned up legacy gallo-claudio@local entry"
    fi
  fi

  log "Done. Restart Claude Code to apply."
  exit 0
fi

# --- pre-flight: check .claude-plugin/ exists ---
if [[ ! -f "${INSTALL_PATH}/.claude-plugin/plugin.json" ]]; then
  err "Missing .claude-plugin/plugin.json in ${INSTALL_PATH}"
  err "This file is required for Claude Code to recognize the plugin."
  exit 1
fi

if [[ ! -f "${INSTALL_PATH}/.claude-plugin/marketplace.json" ]]; then
  err "Missing .claude-plugin/marketplace.json in ${INSTALL_PATH}"
  err "This file is required to register the local marketplace."
  exit 1
fi

# --- clean up legacy install if present ---
PLUGINS_FILE="${HOME}/.claude/plugins/installed_plugins.json"
if [[ -f "$PLUGINS_FILE" ]] && command -v jq &>/dev/null; then
  if jq -e '.plugins["gallo-claudio@local"]' "$PLUGINS_FILE" &>/dev/null; then
    jq 'del(.plugins["gallo-claudio@local"])' "$PLUGINS_FILE" > "${PLUGINS_FILE}.tmp" \
      && mv "${PLUGINS_FILE}.tmp" "$PLUGINS_FILE"
    log "Cleaned up legacy gallo-claudio@local entry"
  fi
fi

# --- install ---
log "Installing gallo-claudio from: ${INSTALL_PATH}"

# Step 1: Register directory as a local marketplace
log "Registering local marketplace: ${MARKETPLACE_NAME}"
if claude plugins marketplace add "${INSTALL_PATH}" 2>&1 | grep -q "Successfully\|already"; then
  log "Marketplace registered"
else
  # Marketplace may already exist — try to continue
  warn "Marketplace registration returned unexpected output (may already exist)"
fi

# Step 2: Install the plugin from the marketplace
log "Installing plugin: ${PLUGIN_NAME}"
if claude plugins install "${PLUGIN_NAME}" 2>&1 | grep -q "Successfully\|already"; then
  log "Plugin installed"
else
  warn "Plugin install returned unexpected output (may already be installed)"
fi

# --- verify ---
echo ""
if claude plugins list 2>&1 | grep -q "gallo-claudio.*enabled"; then
  log "Installation complete! Plugin is enabled."
else
  warn "Plugin installed but may not be enabled. Check: claude plugins list"
fi

echo ""
echo "  Plugin:      ${PLUGIN_NAME}"
echo "  Marketplace: ${MARKETPLACE_NAME}"
echo "  Path:        ${INSTALL_PATH}"
echo ""
echo "  Next steps:"
echo "    1. Restart Claude Code (or start a new session)"
echo "    2. Verify with: claude plugins list"
echo "    3. Available agents: data-engineer, platform-architect, field-ecologist, etc."
echo "    4. Available commands: /terraform-provision, /camera-trap, /birdnet-audio, etc."
echo ""
echo "  To uninstall: ./install.sh --uninstall"
