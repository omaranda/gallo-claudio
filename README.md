# gallo-claudio

A [Claude Code](https://claude.ai/claude-code) plugin that adds a team of AI specialists to your workflow. It covers web development, data engineering, cloud infrastructure, data science, and ecological fieldwork — just describe what you need and the right specialist activates automatically.

## What's included

- **16 specialist agents** — Claude automatically routes your request to the right expert (web developer, data engineer, ecologist, GIS analyst, and more). No manual selection needed.
- **16 workflow commands** — type `/command-name` to launch step-by-step guided workflows for common tasks like scaffolding APIs, setting up pipelines, or designing ML models.
- **6 MCP server connections** — optional direct access to PostgreSQL, AWS, GitHub, and Atlassian from within Claude.

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) CLI installed and in PATH
- Git
- [jq](https://jqlang.github.io/jq/) (`brew install jq` on macOS) — only needed for legacy cleanup

### Quick install

```bash
git clone git@github.com:omaranda/gallo-claudio.git ~/GitHub/gallo-claudio
cd ~/GitHub/gallo-claudio
./install.sh
```

The script registers this directory as a local Claude Code marketplace and installs the plugin using the official CLI. Restart Claude Code and verify:

```bash
claude plugins list | grep gallo
# Expected: gallo-claudio@gallo-claudio-local  ✔ enabled
```

To uninstall: `./install.sh --uninstall`

### Manual install (without script)

```bash
# Register the local marketplace
claude plugins marketplace add ~/GitHub/gallo-claudio

# Install the plugin
claude plugins install gallo-claudio@gallo-claudio-local
```

## Keeping up to date

```bash
cd ~/GitHub/gallo-claudio && git pull
```

No reinstall required — Claude Code reads the plugin directory live.

## Documentation

- **[User Guide](documentation/user-guide.md)** — How to use agents, commands, and planning mode. Written for all team members, no technical background required.
- **[Technical Reference](documentation/technical-reference.md)** — Full inventory of agents, commands, MCP server configuration, contributing guidelines, and supported technology stack.
