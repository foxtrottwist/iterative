# State Management

File schemas for iterative state persistence. Enables resumption after any interruption.

## Directory Structure

```
.claude/iterative/
├── {task-slug}/
│   ├── state.json      # Machine-readable status
│   ├── brief.md        # Requirements from discovery
│   ├── tasks.md        # (Dev) Task breakdown
│   ├── plan.md         # (Knowledge) Phase breakdown
│   ├── context.md      # Brief summary for iterations
│   ├── progress.md     # Iteration log (critical)
│   ├── guardrails.md   # Accumulated lessons
│   ├── sources/        # (Knowledge) Research inputs
│   └── outputs/        # (Knowledge) Deliverables
└── archive/            # Completed tasks
```

## state.json Schema

### Development Mode

```json
{
  "task": "user-authentication",
  "slug": "user-auth",
  "mode": "development",
  "created": "2026-01-14T10:30:00Z",
  "updated": "2026-01-14T14:22:00Z",
  "phase": "execute",
  "current_task": "T3",
  "current_iteration": 2,
  "tasks": {
    "T1": {
      "status": "done",
      "iterations_used": 3,
      "confirmations_used": 1,
      "verification_passed": true,
      "max_iterations": 5,
      "completed_at": "2026-01-14T11:15:00Z"
    },
    "T2": {
      "status": "done",
      "iterations_used": 5,
      "confirmations_used": 2,
      "verification_passed": true,
      "max_iterations": 8,
      "completed_at": "2026-01-14T12:45:00Z"
    },
    "T3": {
      "status": "confirming",
      "iterations_used": 2,
      "confirmations_used": 1,
      "max_iterations": 10
    },
    "T4": { "status": "pending", "max_iterations": 5 },
    "T5": { "status": "blocked", "reason": "Waiting on T3", "max_iterations": 5 }
  },
  "commits": [
    "abc1234: feat(user-auth): Add User model",
    "def5678: feat(user-auth): Create auth service"
  ]
}
```

### Knowledge Mode

```json
{
  "task": "future-of-work-synthesis",
  "slug": "future-work",
  "mode": "knowledge",
  "domain": "research",
  "created": "2026-01-16T10:00:00Z",
  "updated": "2026-01-16T14:30:00Z",
  "phase": "execute",
  "current_phase": "R3",
  "current_iteration": 2,
  "phases": {
    "R1": {
      "status": "done",
      "iterations_used": 3,
      "confirmations_used": 1,
      "verification_passed": true,
      "max_iterations": 5,
      "completed_at": "2026-01-16T11:00:00Z"
    },
    "R2": {
      "status": "done",
      "iterations_used": 4,
      "confirmations_used": 1,
      "verification_passed": true,
      "max_iterations": 5,
      "completed_at": "2026-01-16T13:00:00Z"
    },
    "R3": {
      "status": "confirming",
      "iterations_used": 2,
      "confirmations_used": 1,
      "max_iterations": 5
    },
    "R4": { "status": "pending", "max_iterations": 8 }
  }
}
```

## Status Values

| Status | Description |
|--------|-------------|
| `pending` | Not yet started |
| `in_progress` | Currently in work iteration loop |
| `confirming` | Work declared done, running mandatory N+1 confirmation |
| `verifying` | Confirmation passed, running verification (quality/code review) |
| `done` | Passed all gates: work, confirmation, verification |
| `blocked` | Cannot proceed |
| `timeout` | Hit max iterations |

### Status Lifecycle

```
pending → in_progress → confirming → verifying → done
                ↑            │            │
                └────────────┴────────────┘
                    (if issues found)
```

## Phase Values

| Phase | Description |
|-------|-------------|
| `discover` | Gathering requirements |
| `plan` | Decomposing into tasks/phases |
| `execute` | Running iteration loops |
| `verify` | Reviewing completed work |
| `deliver` | Final packaging |
| `complete` | Archived |

## brief.md Template

```markdown
# {Task Name}

**Created:** {timestamp}
**Mode:** {development|knowledge}
**Domain:** {feature|bug|refactor|research|writing|analysis|planning}

## Outcome Needed
{What the user wants to achieve}

## Done When
- {Criterion 1}
- {Criterion 2}

## Constraints
- {Constraint 1}

## Approach / Notes
{Technical approach, domain-specific details, open questions}
```

## tasks.md Template (Development)

```markdown
# {Feature} - Tasks

**Created:** {timestamp}
**Total:** {N} tasks
**Status:** {X} done, {Y} in progress, {Z} pending

## Dependencies

T1 → T2 → T3 (sequential)
T4 (independent)

## Tasks

- [ ] **T1**: {title}
  - Files: `{paths}`
  - Criteria: {measurable}
  - Completion: `<signal>T1_DONE</signal>`
  - Max iterations: {N}
  - Depends: {none|T1}
  - Model: {haiku|sonnet|opus}

## Notes

{Context for sub-agents}
```

## plan.md Template (Knowledge)

```markdown
# {Task Name} - Phases

**Created:** {timestamp}
**Domain:** {research|writing|analysis|planning}
**Total:** {N} phases

## Phases

- [ ] **R1**: {title}
  - Criteria: {measurable}
  - Output: `{path}`
  - Max iterations: {N}

## Dependencies

R1 → R2 → R3 → R4 (sequential)
```

## progress.md Format

```markdown
# Progress Log

## T1 - Iteration 1 - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left}
**Blockers:** {issues or "None"}
**Commit:** {hash}

## T1 - Iteration 2 - {timestamp}
**Did:** {what accomplished}
**Remaining:** None
**Signal:** T1_DONE
**Commit:** {hash}

## T2 - Iteration 1 - {timestamp}
...
```

**Rules:**
- Each iteration appends; never modify previous entries
- Include timestamp for resumption tracking
- "Remaining" guides next iteration
- "Signal" marks completion

## context.md Template

Keep brief (<200 words). Provides orientation.

```markdown
# {Task} Context

**Goal:** {One sentence}

**Approach:** {One sentence}

**Key files/outputs:**
- `{path}` — {description}

**Patterns to follow:**
- {Convention or style note}

**Signals:**
- T1/R1: {description of complete}
- T2/R2: {description of complete}
```

## guardrails.md Format

```markdown
# Guardrails

Read before starting any iteration. Append when issues discovered.

## {Pattern Name}
- **When**: {context when this applies}
- **Problem**: {what went wrong}
- **Solution**: {how to avoid}
- **Learned**: {ID} iteration {N}
```

## Recovery Scenarios

### Session Interruption

1. Read `state.json` for current task/phase and iteration
2. Read `progress.md` for last entry
3. Resume from "Remaining" items

### Task/Phase Timeout

1. Mark status as `timeout`
2. Log in progress.md what was attempted
3. Ask user: increase max, simplify criteria, or intervene

### Blocked Task/Phase

1. Document blocker in progress.md
2. Add to guardrails.md if pattern
3. Ask user for input or skip to next unblocked unit

### Conflicting State

If state.json and git/files disagree:

1. Trust git/files (source of truth)
2. Read progress.md for iteration history
3. Rebuild state from progress entries
4. Log discrepancy

## Cleanup

After task completion:

```bash
# Archive with timestamp
mv .claude/iterative/{slug} .claude/iterative/archive/{slug}-$(date +%Y%m%d)

# Or remove if not needed
rm -rf .claude/iterative/{slug}
```

Keep archive for reference—guardrails from past work can seed new tasks.
