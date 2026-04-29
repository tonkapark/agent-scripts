#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
timestamp="$(date +"%Y%m%d-%H%M%S")"

usage() {
  cat <<'EOF'
symlink.sh — symlink this repo into ~/.agents, then tools -> ~/.agents

Defaults:
  repo/rules/*   -> ~/.agents/rules/*
  repo/skills/*  -> ~/.agents/skills/*

  ~/.agents/skills/* -> ~/.claude/skills/*
  ~/.agents/skills/* -> ~/.cursor/skills/*
  ~/.agents/rules/*  -> ~/.cursor/rules/*

Options:
  --agents        Install ~/.agents links (default: on)
  --no-agents     Skip ~/.agents links
  --cursor        Install Cursor links (default: on)
  --no-cursor     Skip Cursor links
  --claude        Install Claude links (default: on)
  --no-claude     Skip Claude links
  --dry-run       Print actions only

Notes:
  - Existing destinations are backed up (timestamped) before replacement.
  - Script is safe to re-run.
EOF
}

do_agents=true
do_cursor=true
do_claude=true
dry_run=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help) usage; exit 0 ;;
    --agents) do_agents=true ;;
    --no-agents) do_agents=false ;;
    --cursor) do_cursor=true ;;
    --no-cursor) do_cursor=false ;;
    --claude) do_claude=true ;;
    --no-claude) do_claude=false ;;
    --dry-run) dry_run=true ;;
    *) echo "Unknown arg: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

say() { printf '%s\n' "$*"; }
run() {
  if $dry_run; then
    say "[dry-run] $*"
    return 0
  fi
  "$@"
}

ensure_parent_dir() {
  local path="$1"
  local parent
  parent="$(dirname "$path")"
  run mkdir -p "$parent"
}

ensure_dir() {
  local dir="$1"
  run mkdir -p "$dir"
}

link_path() {
  local src="$1"
  local dst="$2"

  if ! $dry_run && [[ ! -e "$src" ]]; then
    say "Skip (missing): $src"
    return 0
  fi

  ensure_parent_dir "$dst"

  if [[ -e "$dst" || -L "$dst" ]]; then
    # If it already points where we want, call it OK; otherwise skip and leave it alone.
    if [[ -L "$dst" ]]; then
      local existing
      existing="$(readlink "$dst")"
      if [[ "$existing" == "$src" ]]; then
        say "OK (already linked): $dst -> $src"
        return 0
      fi
    fi
    say "Skip (exists): $dst"
    return 0
  fi

  run ln -s "$src" "$dst"
  if $dry_run; then
    say "[dry-run] would link: $dst -> $src"
  else
    say "Linked: $dst -> $src"
  fi
}

if $do_agents; then
  ensure_dir "${HOME}/.agents/rules"
  ensure_dir "${HOME}/.agents/skills"

  shopt -s nullglob

  for src in "${repo_root}/rules/"*; do
    [[ -f "$src" ]] || continue
    link_path "$src" "${HOME}/.agents/rules/$(basename "$src")"
  done

  for src in "${repo_root}/skills/"*; do
    [[ -d "$src" && ! -L "$src" ]] || continue
    link_path "$src" "${HOME}/.agents/skills/$(basename "$src")"
  done
fi

if $do_claude; then
  ensure_dir "${HOME}/.claude/skills"
  shopt -s nullglob
  for src in "${HOME}/.agents/skills/"*; do
    [[ -d "$src" ]] || continue
    link_path "$src" "${HOME}/.claude/skills/$(basename "$src")"
  done
fi

if $do_cursor; then
  ensure_dir "${HOME}/.cursor/skills"
  ensure_dir "${HOME}/.cursor/rules"

  shopt -s nullglob

  for src in "${HOME}/.agents/skills/"*; do
    [[ -d "$src" ]] || continue
    link_path "$src" "${HOME}/.cursor/skills/$(basename "$src")"
  done

  for src in "${HOME}/.agents/rules/"*; do
    [[ -f "$src" ]] || continue
    link_path "$src" "${HOME}/.cursor/rules/$(basename "$src")"
  done
fi

say "Done."
