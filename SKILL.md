---
name: iterative
description: Task orchestration using stateless iteration loops. Auto-detects mode from context - development (code implementation with build/test gates) or knowledge work (research, writing, analysis, planning). Decomposes work into atomic units, runs fresh-context iterations until completion. Use when user needs to implement features, fix bugs, write documents, conduct research, analyze data, or plan projects. Triggers - /iter, "help me build", "implement", "research", "write a document", "analyze".
---

# Iterative

Task orchestration using fresh-context iteration loops. Work decomposes into atomic units. Each unit runs as multiple stateless passes—context resets every iteration, state persists in files.

## Core Pattern

```
Fresh context EVERY iteration.
State persists in files + git.
Progress file = notes to your next iteration.
```

This builds on the Ralph Wiggum Technique (Geoffrey Huntley): instead of growing conversation history until context degrades, reset the context window every iteration. State lives in files. Each fresh agent reads those files to pick up where the last one left off.

## Mode Detection

Auto-detect from request context:

| Signal | Mode |
|--------|------|
| "implement", "build", "fix bug", "add feature", "refactor", code file references | development |
| "research", "write", "analyze", "plan", "document", "synthesize" | knowledge |
| Ambiguous | Ask user via AskUserQuestion |

**If ambiguous**, use AskUserQuestion:

```yaml
question: "What type of work is this?"
options:
  - "Development (coding, implementation)"
  - "Knowledge work (research, writing, analysis, planning)"
```

## Workflow

```
RESUME?  →  DISCOVER  →  PLAN  →  EXECUTE  →  VERIFY  →  DELIVER
(check      (clarify     (tasks/   (iterate)   (review)  (package)
 state)      scope)       phases)
```

## Phase 0: Resume Check

**Every invocation**, check for existing work:

```bash
ls .claude/iterative/ 2>/dev/null
```

**If state exists**, read `state.json` and present:
```
Found "{task}" at {phase}:
- Completed: {list}
- Current: {id} (iteration {N} of max {M})
- Remaining: {list}

Resume, start fresh, or check status?
```

**If no state**, proceed to Discover.

## Phase 1: Discover

Use the **AskUserQuestion tool** to gather requirements. This built-in tool presents clickable options.

**Core questions** (both modes):
1. What outcome do you need?
2. What does "done" look like?
3. Any constraints?

See [references/interview.md](references/interview.md) for mode-specific question templates.

**Output:**
- Create `.claude/iterative/{task-slug}/`
- Write `brief.md` with requirements
- Write `state.json`: `{ "phase": "plan", "mode": "{dev|knowledge}" }`

## Phase 2: Plan

Decompose into atomic units based on detected mode.

### Development Mode

Decompose into **tasks** (T1, T2, ...). Each task runs as its own iteration loop.

**Task format:**
```markdown
- [ ] **T1**: {title}
  - Files: `{paths}`
  - Criteria: {measurable acceptance}
  - Completion: `<signal>T1_DONE</signal>`
  - Max iterations: {3-15}
  - Depends: {none|T1|T1,T2}
  - Model: {haiku|sonnet|opus}
```

**Model selection:**
| Task Type | Model | Why |
|-----------|-------|-----|
| File operations, grep, simple edits | haiku | Mechanical work |
| Standard implementation | sonnet | Balanced capability |
| Code review, test generation | sonnet | Structured output |
| Complex debugging, architecture | opus | Deep reasoning |

See [references/development.md](references/development.md) for full task format.

### Knowledge Mode

Decompose into **phases** using domain templates:

| Domain | Phases | Use When |
|--------|--------|----------|
| Research | R1→R2→R3→R4 | Synthesizing sources, literature review |
| Writing | D1→D2→D3→D4 | Documents, reports, articles |
| Analysis | A1→A2→A3→A4 | Data interpretation, recommendations |
| Planning | P1→P2→P3→P4 | Decisions, strategy, project planning |

**Phase format:**
```markdown
- [ ] **R1**: {title}
  - Criteria: {measurable acceptance}
  - Output: `{file_path}`
  - Max iterations: {3-8}
```

See [references/knowledge.md](references/knowledge.md) for domain templates.

**Output (both modes):**
- Write `tasks.md` or `plan.md`
- Write `context.md` (brief summary for sub-agents)
- Create empty `guardrails.md` and `progress.md`
- Update `state.json`
- Present plan for user approval

**After plan approval**, use AskUserQuestion:

```yaml
question: "Clear context before starting execution?"
options:
  - "Yes - start fresh (recommended for complex tasks)"
  - "No - continue in current session"
```

Clearing context ensures the orchestrator starts execution without accumulated conversation history. The plan and state files provide all necessary context for the execution phase.

## Phase 3: Execute (Iteration Loop)

Each task/phase runs as its own loop of fresh-context iterations, then passes through verification gates.

```
┌─────────────────────────────────────────────────┐
│  TASK/PHASE LOOP                                │
│                                                 │
│  Iteration 1: Fresh agent → reads state → works │
│       ↓                                         │
│  Iteration N: Agent declares DONE               │
│       ↓                                         │
│  Programmatic checks (dev: build, lint, tests)  │
│       ↓                                         │
│  Confirmation pass (N+1): Fresh agent, same task│
│       ↓                                         │
│  Verification agent: Quality/code review        │
│       ↓                                         │
│  Task/phase complete                            │
└─────────────────────────────────────────────────┘
```

See [references/verification.md](references/verification.md) for the complete verification hierarchy.

### Dispatch Fresh Sub-Agent (Each Iteration)

**Critical**: Each iteration spawns a completely fresh sub-agent. No memory of previous iterations except what's in files.

```
Iteration {I} of {MAX} for {ID}: "{title}"

Read these files first (your only memory):
- .claude/iterative/{slug}/progress.md
- .claude/iterative/{slug}/guardrails.md
- .claude/iterative/{slug}/context.md

Task/Phase: {title}
Files/Output: {paths}
Criteria: {acceptance}

Your job this iteration:
1. Read progress.md to see what previous iterations accomplished
2. Continue from where they left off
3. Work toward the criteria
4. Save your work (dev: commit, knowledge: save output)
5. Update progress.md with what you did and what remains
6. If criteria fully met: <signal>{ID}_DONE</signal>
7. If blocked: <signal>BLOCKED:{reason}</signal>

If not done and not blocked, just exit. Next iteration will continue.
```

See [references/prompts.md](references/prompts.md) for all iteration prompt templates.

### Progress File is Critical

The progress file bridges context windows. Each iteration appends:

```markdown
## {ID} - Iteration {I} - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left, or "None"}
**Blockers:** {issues, or "None"}
**Commit/Output:** {reference}

[If complete: **Signal:** {ID}_DONE]
```

### Fresh Context Discipline

**Include** in sub-agent prompt:
- Task/phase ID, title, criteria
- Current iteration number and max
- File paths to read (progress, guardrails, context)
- File paths to modify/output

**Exclude** from sub-agent prompt:
- Full brief/PRD content
- Other task/phase details
- Previous iteration outputs
- Conversation history

**Let agents read files.** Don't paste content into prompts.

### Completion Gates

When an agent declares DONE, the work passes through verification gates:

1. **Programmatic checks** (dev mode) — Build and lint must pass
2. **Test gate** (dev mode) — Generate tests, run all tests
3. **Confirmation pass (N+1)** — Fresh agent receives same prompt, attempts to complete. If truly done, finds nothing to do.
4. **Verification agent** — Quality/code review with adversarial mindset

Only after all gates pass is the unit marked complete.

## Phase 4: Verify (Task Review)

Review completed work against original brief. Runs as iteration loop until PASS.

```
Review iteration {I} for "{task}".

Read:
- .claude/iterative/{slug}/brief.md (requirements)
- .claude/iterative/{slug}/{tasks|plan}.md (criteria per unit)
- .claude/iterative/{slug}/progress.md (what was done)

Verify each completed unit:
1. Acceptance criteria explicitly met
2. Outputs exist and are complete
3. Quality standards satisfied
4. (Dev) Build passes, tests pass

If ALL checks pass: <signal>REVIEW_PASS</signal>
If issues found: <signal>REVIEW_FAIL</signal> with issue list
```

**On REVIEW_FAIL:**
- Dispatch fix/revise loop per issue
- Re-run review
- Repeat until PASS or max review cycles

## Phase 5: Deliver

1. Compile final outputs
2. Present summary:
   ```
   Task: {name}
   Mode: {development|knowledge}
   Units: {N} completed
   Total iterations: {sum}
   Outputs/Files: {list}
   ```
3. Archive state to `.claude/iterative/archive/{slug}/`
4. Update `state.json`: `{ "phase": "complete" }`

## State Files

All state lives in `.claude/iterative/{task-slug}/`:

```
.claude/iterative/
├── {task-slug}/
│   ├── state.json      # Phase, current unit, iteration count
│   ├── brief.md        # Requirements from discovery
│   ├── tasks.md        # (Dev) Task breakdown
│   ├── plan.md         # (Knowledge) Phase breakdown
│   ├── context.md      # Brief summary for sub-agents
│   ├── progress.md     # Iteration log (critical)
│   ├── guardrails.md   # Accumulated lessons
│   ├── sources/        # (Knowledge) Research inputs
│   └── outputs/        # (Knowledge) Deliverables
└── archive/            # Completed work
```

See [references/state.md](references/state.md) for full schemas.

## Guardrails

Sub-agents read `guardrails.md` before starting and append when they hit problems:

```markdown
## {Pattern Name}
- **When**: {context when this applies}
- **Do**: {what to do instead}
- **Learned**: {ID} iteration {N} - {brief reason}
```

Guardrails accumulate across iterations and tasks. Every fresh agent benefits from past lessons.

## Resuming

**After interruption** (network, timeout, new session):

1. Skill detects existing state
2. Reads `state.json` for phase, current unit, iteration
3. Reads `progress.md` for what happened
4. Resumes at exact iteration point

```
Found "{task}" in execute phase:
- Unit: T3 "Create auth service"
- Iteration: 2 of 10
- Last progress: "Added login method, working on token refresh"

Resume from iteration 3?
```

**Commands:**
- `/iter resume` — Continue from exact point
- `/iter status` — Check progress
- `/iter skip-to {phase}` — Jump to phase

## Anti-Patterns

- **Carrying context**: Passing previous iteration output into next prompt
- **Giant units**: Let iterations handle complexity, but scope reasonably
- **Skipping progress updates**: Next iteration has no idea what happened
- **Ignoring guardrails**: Repeat past mistakes across iterations
- **Too few iterations**: Complex work needs room to converge
- **Too many iterations**: Thrashing without progress wastes resources

## Quick Reference

| Command | Action |
|---------|--------|
| `/iter {description}` | Start new task (auto-detect mode) |
| `/iter resume` | Continue from exact point |
| `/iter status` | Check progress with iteration counts |
| `/iter skip-to {phase}` | Jump to phase |

## Attribution

This skill builds on the Ralph Wiggum Technique (Geoffrey Huntley): a loop that repeatedly invokes an agent with a prompt file, allowing iterative refinement until completion. Instead of growing conversation history until context degrades, reset the context window every iteration. State lives in files. Each fresh agent reads those files to pick up where the last one left off.

Anthropic's documentation on long-running agents and sub-agent coordination informed the dispatch mechanics.
