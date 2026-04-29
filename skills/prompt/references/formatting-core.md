# Prompt Formatting Core — Shared Reference

*v2.1 — Shared formatting rules, depth calibration, domain shaping, and tool routing for the /prompt family*

---

## Token Conventions (lightweight)

When the input includes inline tokens, treat them as configuration, not part of the user’s natural-language request:

- `mode:run` (default) or `mode:format`
- `domain:general` (default), `domain:dev`, `domain:research`
- `depth:light` (default), `depth:standard`, `depth:deep`
- Literal token `council` is opt-in routing (handled by `/prompt`, not needed for `/prompt-only`)

If tokens conflict with plain-language instructions, **prefer the explicit tokens**.

## Formatting Elements

When formatting a prompt, apply these elements as appropriate (not all are needed for every prompt):

- **Role/persona** — include only when specialized expertise sharpens the output
- **Task** — stated clearly in 1-2 sentences (always include)
- **Context** — relevant background the model needs
- **Constraints** — length, tone, format, what to avoid
- **Output format** — specify structure (bullets, table, sections, etc.)
- **Bookend pattern** — restate the key instruction at the end if the prompt is long
- **Examples** — include only if they would reduce ambiguity (try zero-shot first)

**Scaling rule:** Match formatting complexity to task complexity. A 1-sentence ask doesn't need a 20-line prompt.

---

## Domain Shaping (make prompts work broadly)

Use `domain:` to add *just enough* structure so the output is stronger for that domain, without bloating simple asks.

### `domain:general` (default)

- Keep it lean: clear task + minimal constraints + crisp output format.
- Prefer concrete examples only if ambiguity is high.

### `domain:dev` (software development)

Add these only when relevant:

- **Environment & constraints**: language/runtime/framework, existing codebase context, performance/security constraints, style preferences.
- **Correctness hooks**: ask for edge cases, failure modes, and a quick test plan when building code.
- **Output structure suggestion** (typical): Approach → Implementation steps → Code (if needed) → Edge cases → Test plan.

### `domain:research` (academic research)

Add these only when relevant:

- **Claim discipline**: separate what is known vs. assumptions vs. what needs verification.
- **Method clarity**: if methods/design are requested, ask for identification strategy, threats to validity, and data requirements.
- **Output structure suggestion** (typical): Research question → Prior/positioning → Method/plan → Assumptions → Limitations → Next steps.

---

## Depth Calibration

Before formatting, assess how much depth this task needs. **Default to Light** (format only). Depth injection is additive, not automatic.

### Heuristic

| Level | When to use | User override |
|-------|-------------|---------------|
| **Light** | Default. Quick replies, simple lookups, routine tasks, short emails | `depth:light` |
| **Standard** | Analysis, research, writing, or design where output quality depends on rigor | `depth:standard` |
| **Deep** | High stakes: methodology, identification strategy, grant proposals; or when user explicitly asks for thoroughness | `depth:deep` |

### Escalation signals (upgrade from Light)

- Task involves synthesis, analysis, or original argument → **Standard**
- Task involves research design, causal inference, or policy implications → **Standard** or **Deep**
- Words like "comprehensive," "thorough," "rigorous" in the request → **Standard** or **Deep**
- High-stakes deliverables (pre-analysis plan, grant proposal, methodology section) → **Deep**

---

## Depth-Injection Templates

### Light (default)
No injection. Format the prompt using the elements above. Done.

### Standard — append to formatted prompt:
```
Include at the end:
- Key assumptions (2-3 bullets)
- Brief rationale for major choices
```

### Deep — append to formatted prompt:
```
Before answering:
- Research current best practices for [task domain]
- Compare your approach against established standards in [domain]
- Flag where your approach deviates and why

Include at the end:
- Key assumptions (2-3 bullets)
- Brief rationale for major choices
- What you verified and what remains uncertain
```

---

## Tool-Routing Awareness

After formatting, check whether the task is better suited to another tool. Brief note, not blocking.

| Signal | Suggested tool | Reason |
|--------|---------------|--------|
| Deep multi-source literature review, "find everything about X" | ChatGPT Deep Research | Better web synthesis |
| Citation-heavy factual lookup, sourced answers | Perplexity | Inline citations, live sources |
| Heavy spreadsheet work (formulas, pivots, formatting) | Gemini | Native Sheets integration |
| Video/audio analysis | Gemini | Can process media directly |
| Otherwise | Proceed in Claude Code | Strong at reasoning, editing, local files |

**For `/prompt`**: Add a brief note before executing if another tool would serve better.
**For `/prompt-only`**: Add `**Best run in:** [tool] — [reason]` after the code block.
**For `/prompt-refine`**: Note in the changes list if the refined prompt would benefit from a specific tool.