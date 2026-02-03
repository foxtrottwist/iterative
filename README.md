# Iterative

A Claude Code skill for task orchestration using fresh-context iteration loops.

## The Problem

Long-running tasks degrade as conversation history grows. The context window fills with outdated information, Claude loses track of the current state, and quality drops.

## The Solution

Reset context every iteration. State persists in files, not conversation history. Each fresh agent reads those files to continue where the last one stopped.

This builds on the [Ralph Wiggum Technique](https://ghuntley.com/specs/ralph-wiggum/) by Geoffrey Huntley.

## Installation

Download the latest `.skill` file from [Releases](https://github.com/foxtrottwist/iterative/releases) and extract to `~/.claude/skills/iterative/`.

Or clone directly:

```bash
git clone https://github.com/foxtrottwist/iterative.git ~/.claude/skills/iterative
```

## Usage

```bash
/iter implement user authentication with JWT tokens
/iter research best practices for API rate limiting
/iter write a technical design doc for the caching layer
```

The skill auto-detects whether you need development mode (coding, implementation) or knowledge work mode (research, writing, analysis).

## How It Works

### Workflow

```
RESUME? → PLAN MODE → CONTEXT CLEAR → EXECUTE → VERIFY → DELIVER
```

1. **Plan mode**: Gather requirements, explore codebase, decompose into tasks
2. **Context clear**: Claude Code's built-in feature wipes history after plan approval
3. **Execute**: Fresh orchestrator dispatches subagents for each task
4. **Verify**: Check outputs against original requirements
5. **Deliver**: Package results, archive state

### State Files

All state lives in `.claude/iterative/{task-slug}/`:

```
state.json      # Phase, current task, iteration count
brief.md        # Requirements from discovery
tasks.md        # Task breakdown with acceptance criteria
progress.md     # Iteration log (how agents communicate across resets)
guardrails.md   # Lessons learned (prevents repeating mistakes)
```

### Iteration Loop

Each task runs as multiple passes:

```
┌─────────────────────────────────────────────────┐
│  Iteration 1: Fresh agent → reads state → works │
│       ↓                                         │
│  Iteration N: Agent signals DONE                │
│       ↓                                         │
│  Verification gates (build, test, review)       │
│       ↓                                         │
│  Task complete                                  │
└─────────────────────────────────────────────────┘
```

The progress file bridges context windows. Each iteration appends what it did, what remains, and any blockers.

## Resuming

After interruption, the skill reads state files and continues from the exact point:

```
Found "auth-implementation" in execute phase:
- Task: T3 "Create auth service"
- Iteration: 2 of 10
- Last progress: "Added login method, working on token refresh"

Resume from iteration 3?
```

Commands:
- `/iter resume` — Continue from exact point
- `/iter status` — Check current progress
- `/iter skip-to {phase}` — Jump to a specific phase

## Key Concepts

**Fresh context discipline**: Each subagent spawns with no memory except what's in files. Don't paste previous outputs into prompts—let agents read files.

**Guardrails accumulate**: When agents hit problems, they add entries to `guardrails.md`. Every future agent benefits from past lessons.

**Verification gates**: After an agent declares DONE, work passes through programmatic checks, a confirmation pass (fresh agent tries the same task), and a verification agent review.

## Attribution

- [Ralph Wiggum Technique](https://ghuntley.com/specs/ralph-wiggum/) by Geoffrey Huntley
- Anthropic's documentation on long-running agents and sub-agent coordination

## License

MIT
