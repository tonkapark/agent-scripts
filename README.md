# agent-scripts

Personal collection of agent **rules**, **skills**, and related docs, maintained in one repo and **symlinked** into:

- `~/.agents/` (primary)
- `~/.claude/` (symlinked to `~/.agents/`)
- `~/.cursor/` (symlinked to `~/.agents/`)

The source of truth lives in this repository so it can be versioned, shared on GitHub, and managed with open-source tooling (e.g. [Chops](https://chops.md/)).

Skills follow the open [Agent Skills spec](https://agentskills.io/specification) (`SKILL.md` with YAML frontmatter + Markdown body), with a small compatibility exception: some skills include `argument-hint` for older command-style clients and likely future support (see [`anthropics/claude-code#43401`](https://github.com/anthropics/claude-code/issues/43401)).

## Layout

- `rules/` — Cursor rules (`.mdc`)
- `skills/` — Agent skills (one folder per skill, each with `SKILL.md`)
- `scripts/` — install/uninstall helpers (symlinks + backups)

## Install (symlinks)

Run from the repo root:

```bash
./scripts/symlink.sh
```

This will:

- back up any existing destination folders (timestamped)
- create symlinks from this repo into your dotfolders
- be safe to re-run (idempotent)

## What gets installed

- `rules/` → `~/.agents/rules`
- `skills/` → `~/.agents/skills`
- `~/.claude/skills` → `~/.agents/skills`
- `~/.cursor/skills` → `~/.agents/skills`
- `~/.cursor/rules` → `~/.agents/rules`

## Maintenance workflow

- Add or edit a rule: `rules/*.mdc`
- Add a new skill: `skills/<skill-name>/SKILL.md`
- Re-run install after changes: `./scripts/install.sh`

## Included

Rules:

- `rules/kaparthy.mdc` — Karpathy behavioral guidelines (alwaysApply)

Skills:

- `skills/build/` — feature development pipeline
- `skills/prompt/` — prompt formatter + optional execution
- `skills/research/` — deep research before planning
- `skills/new-rails-project/` — generate a Rails project boilerplate

## Managing with Chops

Chops discovers skills and rules by scanning the standard dotfolders (including `~/.agents/skills`, `~/.claude/skills`, `~/.cursor/rules`, and `~/.cursor/skills`). This repo’s symlink-based install is designed to work well with that model.

## Inspiration

- https://github.com/shpigford/skills
- https://github.com/forrestchang/andrej-karpathy-skills
- https://github.com/steipete/agent-scripts


## License

MIT. See `LICENSE`.
