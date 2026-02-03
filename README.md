# Iterative

Task orchestration for Claude Code using fresh-context iteration loops.

## What It Does

Break complex work into atomic units. Run each unit through multiple iterations where context resets every pass but state persists in files. This prevents context window degradation on long-running tasks.

Works for both:
- **Development**: implementing features, fixing bugs, refactoring code
- **Knowledge work**: research, writing documents, analysis, planning

The skill auto-detects which mode based on your request.

## Installation

Download the latest `.skill` file from [Releases](https://github.com/foxtrottwist/iterative/releases) and extract to `~/.claude/skills/iterative/`.

Or clone directly:
```bash
git clone https://github.com/foxtrottwist/iterative.git ~/.claude/skills/iterative
```

## Usage

```
/iter implement user authentication with JWT tokens
/iter research best practices for API rate limiting
/iter write a technical design doc for the caching layer
```

The skill will:
1. Enter plan mode to gather requirements and explore the codebase
2. Decompose work into tasks with acceptance criteria
3. Offer to clear context before execution (keeps orchestrator lean)
4. Dispatch fresh subagents for each task iteration
5. Verify completion through multiple gates

## How It Works

This builds on the [Ralph Wiggum Technique](https://ghuntley.com/specs/ralph-wiggum/) (Geoffrey Huntley): instead of growing conversation history until context degrades, reset the context window every iteration. State lives in files. Each fresh agent reads those files to pick up where the last one left off.

```
Fresh context EVERY iteration.
State persists in files + git.
Progress file = notes to your next iteration.
```

### Workflow

```
RESUME? → PLAN MODE → CONTEXT CLEAR → EXECUTE → VERIFY → DELIVER
```

- **Plan mode**: Explore codebase, interview for requirements, write plan
- **Context clear**: Built-in Claude Code feature clears history after plan approval
- **Execute**: Fresh orchestrator dispatches subagents per task
- **Verify**: Review against original requirements
- **Deliver**: Package outputs, archive state

### State Files

All state lives in `.claude/iterative/{task-slug}/`:

```
state.json      # Phase, current task, iteration count
brief.md        # Requirements from discovery
tasks.md        # Task breakdown with acceptance criteria
progress.md     # Iteration log (critical for continuity)
guardrails.md   # Accumulated lessons across iterations
```

## Resuming

After interruption, run `/iter resume`. The skill reads state files and continues from the exact iteration point.

```
Found "auth-implementation" in execute phase:
- Task: T3 "Create auth service"
- Iteration: 2 of 10
- Last progress: "Added login method, working on token refresh"

Resume from iteration 3?
```

## Attribution

- Ralph Wiggum Technique by [Geoffrey Huntley](https://ghuntley.com/specs/ralph-wiggum/)
- Anthropic's documentation on long-running agents and sub-agent coordination

## License

MIT
