#!/usr/bin/env bash
# =============================================================================
# install.sh — galloClaudio plugin installer for Claude Code
# Usage: ./install.sh [--uninstall]
# =============================================================================
set -euo pipefail

PLUGIN_NAME="galloClaudio@local"
PLUGIN_VERSION="1.1.0"
CLAUDE_DIR="${HOME}/.claude"
PLUGINS_FILE="${CLAUDE_DIR}/plugins/installed_plugins.json"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"
INSTALL_PATH="$(cd "$(dirname "$0")" && pwd)"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
log()  { echo -e "${GREEN}[galloClaudio]${NC} $*"; }
warn() { echo -e "${YELLOW}[galloClaudio]${NC} $*"; }
err()  { echo -e "${RED}[galloClaudio]${NC} $*" >&2; }

# --- dependency check ---
if ! command -v jq &>/dev/null; then
  err "jq is required but not installed."
  echo "  brew install jq    # macOS"
  echo "  apt install jq     # Debian/Ubuntu"
  exit 1
fi

# --- uninstall ---
if [[ "${1:-}" == "--uninstall" ]]; then
  log "Uninstalling ${PLUGIN_NAME}..."

  if [[ -f "$PLUGINS_FILE" ]]; then
    jq "del(.plugins[\"${PLUGIN_NAME}\"])" "$PLUGINS_FILE" > "${PLUGINS_FILE}.tmp" \
      && mv "${PLUGINS_FILE}.tmp" "$PLUGINS_FILE"
    log "Removed from installed_plugins.json"
  fi

  if [[ -f "$SETTINGS_FILE" ]]; then
    jq "del(.enabledPlugins[\"${PLUGIN_NAME}\"])" "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
      && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"
    log "Removed from settings.json"
  fi

  log "Done. Restart Claude Code to apply."
  exit 0
fi

# --- install ---
log "Installing galloClaudio from: ${INSTALL_PATH}"

# Ensure directories exist
mkdir -p "${CLAUDE_DIR}/plugins"

# --- installed_plugins.json ---
if [[ ! -f "$PLUGINS_FILE" ]]; then
  echo '{"version":2,"plugins":{}}' > "$PLUGINS_FILE"
  log "Created ${PLUGINS_FILE}"
fi

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")

jq --arg name "$PLUGIN_NAME" \
   --arg path "$INSTALL_PATH" \
   --arg ver "$PLUGIN_VERSION" \
   --arg ts "$TIMESTAMP" \
   '.plugins[$name] = [{
     "scope": "user",
     "installPath": $path,
     "version": $ver,
     "installedAt": $ts,
     "lastUpdated": $ts,
     "gitCommitSha": "local"
   }]' "$PLUGINS_FILE" > "${PLUGINS_FILE}.tmp" \
  && mv "${PLUGINS_FILE}.tmp" "$PLUGINS_FILE"

log "Registered in installed_plugins.json"

# --- settings.json ---
if [[ ! -f "$SETTINGS_FILE" ]]; then
  echo '{"enabledPlugins":{}}' > "$SETTINGS_FILE"
  log "Created ${SETTINGS_FILE}"
fi

jq --arg name "$PLUGIN_NAME" \
   '.enabledPlugins[$name] = true' "$SETTINGS_FILE" > "${SETTINGS_FILE}.tmp" \
  && mv "${SETTINGS_FILE}.tmp" "$SETTINGS_FILE"

log "Enabled in settings.json"

# --- summary ---
echo ""
log "Installation complete!"
echo ""
echo "  Plugin:  ${PLUGIN_NAME}"
echo "  Path:    ${INSTALL_PATH}"
echo "  Version: ${PLUGIN_VERSION}"
echo ""
echo "  Next steps:"
echo "    1. Restart Claude Code"
echo "    2. Run /plugin to verify galloClaudio@local is listed"
echo "    3. (Optional) Set env vars for MCP servers:"
echo "       export DATABASE_URL=\"postgresql://user:pass@host:5432/db\""
echo "       export AWS_PROFILE=\"your-profile\""
echo "       export AWS_REGION=\"eu-central-1\""
echo ""
echo "  To uninstall: ./install.sh --uninstall"
