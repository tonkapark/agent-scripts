---
name: prompt
description: Turn a natural, conversational request into a strong structured prompt, then either display it or execute it. Use when the user wants better prompts for broad knowledge, software development, or academic research, with explicit control over format-only vs format+run.
compatibility: Designed for Cursor agents and Claude Code-style agents that support command skills and tool execution.
metadata:
  version: "2.3-tonkapark"
  upstream:
    repo: https://github.com/chrisblattman/claudeblattman
    note: "Initial version derived from this repository; local copy has been modified."
---

## /prompt — Format and Execute

Format an informal request into a structured prompt. By default, do not execute it.

## Reference Files

- `references/formatting-core.md`

## Input

$ARGUMENTS

## Options (inline tokens)

- **`mode:run`**: Format, show the prompt, then execute it.
- **`mode:format`**: Format and show the prompt only. Do **not** execute.
- **`domain:general`**: Broad knowledge, writing, planning (default).
- **`domain:dev`**: Software development (code, debugging, design, refactors).
- **`domain:research`**: Academic research (literature, methods, claims, structure).
- **`depth:light` / `depth:standard` / `depth:deep`**: Depth calibration (default is `depth:light`).
- **`council`**: Opt-in dispatch to `/council` after formatting (never default).

## Instructions

You are a prompt formatter. The user has given you an informal, conversational request (possibly dictated). Your job:

1. **Parse the intent**: Extract the core task, audience, and desired output from the informal input.

2. **Parse tokens** (if present): `mode:*`, `domain:*`, `depth:*`, and optional `council`.

3. **Calibrate depth** using the heuristic in `references/formatting-core.md`:
   - **Light** (default): Format only. No depth injection.
   - **Standard**: Format + append assumptions/rationale block.
   - **Deep**: Format + append research/compare/verify block.
   - User can override with `depth:light`, `depth:standard`, or `depth:deep`.

4. **Apply domain shaping** (if `domain:dev` or `domain:research`) using the domain guidance in `references/formatting-core.md`. For `domain:general`, keep it lean.

5. **Format into a structured prompt** using the formatting elements in `references/formatting-core.md`. Apply elements as appropriate — match formatting complexity to task complexity.

6. **Inject depth directives** if Standard or Deep (per the templates in `references/formatting-core.md`). For Light, skip this step entirely.

7. **Show the formatted prompt** in a fenced code block so the user can see exactly what will run.

8. **Tool-routing check**: If another tool would serve this task better (see `references/formatting-core.md`), add a brief note before executing. Don't block — just flag it.

9. **Council opt-in**: If the input contains the literal token `council`, do NOT execute directly. Instead, after formatting, invoke `/council` with the formatted prompt as the topic.

10. **Execution rule**:
   - If `mode:format` is present, **do not execute**.
   - If the user says "hold" / "don't run" / "just format", treat as **`mode:format`**.
   - Otherwise (default `mode:format`), **do not execute** — stop after showing the formatted prompt.
   - Only execute if `mode:run` is present or the user explicitly asks you to run it.

11. **Ask ONE clarifying question ONLY if** the ambiguity would lead to a significantly different output. Otherwise, make reasonable assumptions and proceed.

## Important
- Do NOT over-engineer simple requests. A 1-sentence ask doesn't need a 20-line prompt.
- Match complexity of formatting to complexity of task.
- Light depth is the default — most requests should pass through with formatting only.
- Prefer explicit tokens when present: `mode:*`, `domain:*`, `depth:*`.
- `council` token handling: opt-in only. `/prompt X depth:deep council` → format, then dispatch via `/council`. `/prompt X` → format + execute directly (no council).
- Use tools (file access/search/web) when executing if the task requires them.