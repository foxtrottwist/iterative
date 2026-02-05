# Iterative

A Claude Code skill for task orchestration with verification gates and domain-specific decomposition.

## What It Does

Layers specialized behaviors on top of Claude Code's native Task system:

- **Verification gates** — Confirmation passes (N+1) and adversarial verification agents catch incomplete or flawed work
- **Domain templates** — Structured decomposition for development (T1, T2, ...) and knowledge work (R1-R4, D1-D4, A1-A4, P1-P4)
- **Guardrails accumulation** — Lessons learned persist in `.claude/guardrails.md` across sessions
- **Mode detection** — Auto-detects development vs knowledge work from context

The native Task tool handles fresh-context subagents, state persistence, session resumption, and parallel execution.

## Installation

Clone to your skills directory:

```bash
git clone https://github.com/foxtrottwist/iterative.git ~/.claude/skills/iterative
```

## Usage

```bash
/iter implement user authentication with JWT tokens
/iter research best practices for API rate limiting
/iter write a technical design doc for the caching layer
```

## Workflow

```
PLAN MODE  →  DECOMPOSE  →  TASK DISPATCH  →  VERIFY  →  DELIVER
```

1. **Plan mode**: Gather requirements via AskUserQuestion, decompose using domain templates
2. **Task dispatch**: Execute each unit via native Task tool with model selection
3. **Verify**: Programmatic checks, confirmation pass (N+1), verification agent
4. **Deliver**: Cross-unit review, present summary

## Structure

```
iterative/
├── SKILL.md              # Orchestration layer (~190 lines)
├── scripts/
│   └── verify-completion.sh
└── references/
    ├── interview.md      # Discovery question templates
    ├── development.md    # Task format, model selection, gates
    ├── knowledge.md      # Phase templates (R/D/A/P)
    └── verification.md   # Verification hierarchy, stub detection
```

## Attribution

- [Ralph Wiggum Technique](https://ghuntley.com/specs/ralph-wiggum/) by Geoffrey Huntley
- [Get Shit Done](https://github.com/glittercowboy/get-shit-done) by glittercowboy — checkpoint types, stub detection levels, automation-first verification
- Anthropic's documentation on long-running agents and sub-agent coordination

## License

MIT
