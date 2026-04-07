# gallo-claudio

A [Claude Code](https://claude.ai/claude-code) plugin that adds a team of AI specialists to your workflow. It covers web development, data engineering, cloud infrastructure, data science, and ecological fieldwork — just describe what you need and the right specialist activates automatically.

## What's included

- **16 specialist agents** — Claude automatically routes your request to the right expert (web developer, data engineer, ecologist, GIS analyst, and more). No manual selection needed.
- **16 workflow commands** — type `/command-name` to launch step-by-step guided workflows for common tasks like scaffolding APIs, setting up pipelines, or designing ML models.
- **6 MCP server connections** — optional direct access to PostgreSQL, AWS, GitHub, and Atlassian from within Claude.

## Installation

### Prerequisites

- [Claude Code](https://claude.ai/claude-code) installed
- Git
- [jq](https://jqlang.github.io/jq/) (`brew install jq` on macOS)

### Quick install

```bash
git clone git@github.com:omaranda/gallo-claudio.git ~/GitHub/gallo-claudio
cd ~/GitHub/gallo-claudio
./install.sh
```

Restart Claude Code and run `/plugin` to verify that `gallo-claudio@local` appears in the list.

To uninstall: `./install.sh --uninstall`

## Keeping up to date

```bash
cd ~/GitHub/gallo-claudio && git pull
```

No reinstall required — Claude Code reads the plugin directory live.

## Documentation

- **[User Guide](documentation/user-guide.md)** — How to use agents, commands, and planning mode. Written for all team members, no technical background required.
- **[Technical Reference](documentation/technical-reference.md)** — Full inventory of agents, commands, MCP server configuration, contributing guidelines, and supported technology stack.
