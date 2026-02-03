# Verification Hierarchy

Defense-in-depth strategy for validating work. Each layer catches different failure modes.

## The Problem

Agents are fallible. Even well-scoped tasks/phases can fail in subtle ways:
- Confirmation bias (agent thinks their work is correct)
- Shallow completion (meets letter of criteria, not intent)
- Missing edge cases/nuances
- Quality gaps (works but lacks depth or rigor)

**The core question:** When an agent declares "done" after one iteration, is that because:
1. The task was well-defined and genuinely complete? OR
2. The agent was overconfident and we got lucky?

We cannot distinguish these without independent validation.

## Verification Layers

```
┌─────────────────────────────────────────────────────────────┐
│                     HUMAN REVIEW                            │
│  Final authority. Judgment calls. Quality assessment.       │
├─────────────────────────────────────────────────────────────┤
│                   TASK REVIEW                               │
│  Cross-unit integration. Coherence. Completeness.           │
├─────────────────────────────────────────────────────────────┤
│              VERIFICATION AGENT (Quality/Code Review)       │
│  Adversarial scrutiny. Depth check. Gap analysis.           │
├─────────────────────────────────────────────────────────────┤
│            MANDATORY CONFIRMATION PASS (N+1)                │
│  Fresh agent attempts the SAME task. Independent agreement. │
├─────────────────────────────────────────────────────────────┤
│               PROGRAMMATIC CHECKS (Dev Only)                │
│  Tests. Linting. Type checking. Build verification.         │
├─────────────────────────────────────────────────────────────┤
│              WORK PASS (1...N)                              │
│  Initial work. Agent iterates until it believes done.       │
└─────────────────────────────────────────────────────────────┘
```

## The Key Insight: Work Consensus

The mandatory N+1 pass is **NOT** a verification step. It is another **work attempt**.

- Same prompt as iteration 1: "Complete this task/phase"
- Fresh agent with no memory of doing the work
- Reads criteria, examines outputs/code, decides what needs doing
- If work is truly complete → agent finds nothing to do → declares DONE
- If gaps exist → agent naturally finds and fills them → may iterate

This creates **work consensus**: two independent agents, both given the same mandate, both concluding the work is complete.

Only after work consensus do we move to explicit quality review (verification agent).

## Layer Details

### Layer 1: Work Pass (1...N)

**What it is:** Agent works on the task/phase until it believes criteria are met.

**Output:** `PRELIMINARY_DONE` signal (not final)

**Failure mode:** Agent is overconfident, stops too early, or misunderstands criteria.

---

### Layer 2: Programmatic Checks (Development Only)

**What it is:** Automated, objective verification.

| Check | Purpose | Example |
|-------|---------|---------|
| Build | Code compiles | `swift build`, `tsc`, `cargo check` |
| Types | Type safety | `tsc --noEmit`, `mypy` |
| Lint | Style/patterns | `swiftlint`, `eslint`, `rustfmt` |
| Tests | Behavior | `swift test`, `npm test`, `cargo test` |

**What it catches:**
- Syntax errors
- Type mismatches
- Style violations
- Regression bugs

**Output:** Pass/fail for each check. All must pass to proceed.

---

### Layer 3: Mandatory Confirmation Pass (N+1)

**What it is:** Another work attempt with the **exact same prompt** as iteration 1.

**Critical distinction:** This agent doesn't know it's a "confirmation pass." It receives the same instruction the original agent received. It then:
1. Reads task/phase criteria
2. Examines the actual outputs/code
3. Attempts to complete the task/phase
4. If nothing to do → declares DONE
5. If finds work → does it, may iterate further

**What it catches:**
- Incomplete work
- Gaps the first agent missed
- Criteria misunderstandings
- Missing depth or analysis

**When to require:** Always. Every task/phase gets N+1 regardless of complexity.

**Output:**
- DONE (agrees work is complete) → proceed to verification
- Continues working → iterate until DONE, then another N+1

---

### Layer 4: Verification Agent

**What it is:** Dedicated agent with adversarial mindset.

**Purpose:** Independent validation. Actively tries to find problems.

**What it catches (Development):**
- Edge cases (empty, null, boundary values)
- Unhandled error paths
- Logic errors
- Security concerns
- Performance issues

**What it catches (Knowledge):**
- Shallow analysis
- Missing sources/perspectives
- Logical gaps
- Quality issues (clarity, structure, depth)

**Output:** `VERIFIED` or `GAPS_FOUND` with specific issues.

### Stub Detection

Verification must check work is **substantive**, not placeholder. Four verification levels:

| Level | Check | Catches |
|-------|-------|---------|
| Exists | File present at expected path | Missing files |
| Substantive | Real implementation, not placeholder | Stubs, TODOs |
| Wired | Connected to rest of system | Orphaned code |
| Functional | Actually works when invoked | Integration bugs |

**Universal stub patterns (grep for these):**
- Comment stubs: `TODO`, `FIXME`, `PLACEHOLDER`, `implement later`
- Empty returns: `return null`, `return {}`, `return []`
- Log-only functions: `console.log(...); return`
- Placeholder text: `lorem ipsum`, `coming soon`, `example data`

**Development mode - check for:**
- Handlers that only `console.log()` or `preventDefault()`
- Components returning `<div>Placeholder</div>` or `null`
- API routes returning `{ message: "Not implemented" }`
- Queries without awaited results
- State declared but never rendered

**Wiring verification (where 80% of stubs hide):**
- Does component actually call API and use response?
- Does API route actually query database and return result?
- Does form handler actually submit data?
- Is state actually rendered, not hardcoded?

---

### Layer 5: Task Review

**What it is:** Cross-unit verification after all tasks/phases complete.

**Purpose:** Ensure units work together coherently.

**What it catches:**
- Inconsistencies between units
- Missing connections
- Gaps that span units
- Overall coherence and flow

---

### Layer 6: Human Review

**What it is:** Final human approval.

**Purpose:** Ultimate authority on quality and correctness.

**What it catches:**
- Everything above layers might miss
- Judgment calls on quality
- Domain expertise validation
- "Does this actually answer the question?"

## Task/Phase Lifecycle with All Layers

```
Task/Phase Start
│
├─► Work Loop (Agent A, iterations 1...N)
│   └── Agent A declares DONE
│
├─► Programmatic Gate (dev only)
│   └── Build, lint, tests pass?
│
├─► Mandatory Confirmation Pass (Agent B)
│   │
│   │   Agent B receives SAME prompt
│   │   Agent B doesn't know this is confirmation
│   │   Agent B reads criteria, examines work, attempts to complete
│   │
│   ├── Agent B finds work?
│   │   └── Does it → Eventually DONE → Another Agent C
│   │
│   └── Agent B finds nothing?
│       └── DONE → Work consensus achieved
│
├─► Programmatic Gate (dev, again)
│   └── Ensure confirmation work didn't break anything
│
├─► Verification Agent (Quality/Code Review)
│   │
│   │   NOW we explicitly review
│   │   Adversarial mindset: find problems
│   │
│   ├── VERIFIED → Unit complete
│   └── GAPS_FOUND → Fix/revise → Re-verify (max 3 cycles)
│
└─► Unit Complete

After all units complete:
│
├─► Task Review Phase
│   └── Cross-unit integration check
│
└─► Human Review
    └── Final approval
```

## Why This Works

The confirmation pass answers: "Would a different agent, given the same task, agree it's complete?"

- If YES → We have confidence. Two independent attempts, same conclusion.
- If NO → The first agent was overconfident. Good thing we checked.

This is different from verification because:
- Confirmation agent tries to DO work (and finds none if done)
- Verification agent tries to CRITIQUE work (assumes done, looks for flaws)

Both are valuable. Confirmation catches incomplete work. Verification catches flawed work.

## When to Skip Layers

Very few layers are skippable.

| Layer | Skippable? | Rationale |
|-------|------------|-----------|
| Programmatic (dev) | No | Fast, objective, no reason to skip |
| Confirmation (N+1) | No | Core mechanism for catching overconfidence |
| Verification | Rarely | Skip only for trivial tasks |
| Task Review | No | Catches cross-unit issues |
| Human Review | No | Final authority |

## Saturation Detection

**Problem:** Agent iterates without meaningful progress (thrashing).

**Detection heuristics:**
After each iteration, compare to previous:
1. Parse `**Did:**` section from current and prior iteration
2. Calculate semantic similarity (shared keywords, operations)
3. If >80% similar for 2+ consecutive iterations → saturation

**Saturation response:**
```
Saturation detected: Last {N} iterations show <20% change.

Recent activity:
- Iteration {N-2}: {did summary}
- Iteration {N-1}: {did summary}
- Iteration {N}: {did summary}

Options:
1. Continue with fresh approach hint
2. Escalate to user for guidance
3. Skip to next unit
```

**Progress.md enhancement:**
Add `**Delta:**` field tracking what changed from prior iteration:

```markdown
## T1 - Iteration 3 - 2026-01-15T10:30:00Z
**Did:** Fixed auth middleware error handling
**Delta:** Changed 2 files, added error wrapper (vs prior: same 2 files, different error paths)
**Remaining:** None
**Signal:** T1_DONE
```

## Gap Severity Guide

| Severity | Definition | Action |
|----------|------------|--------|
| Critical | Broken functionality, missing major requirement, factual errors | Must fix before proceeding |
| Major | Missing requirement, shallow analysis, unhandled error path | Must fix before proceeding |
| Minor | Style issue, optimization opportunity, minor clarification | Fix in review phase or skip |

## Max Verification Cycles

Prevent infinite verify-fix loops:
- Default: 3 verification attempts per task/phase
- If still failing after 3, escalate to user
- User can: simplify criteria, intervene manually, or accept with known gaps

## Summary

| Layer | Purpose | Catches |
|-------|---------|---------|
| Work Pass | Do the work | — |
| Programmatic (dev) | Objective checks | Syntax, types, regressions |
| **Confirmation (N+1)** | **Independent agreement** | **Incomplete work, misunderstood criteria** |
| Verification | Quality/code review | Shallow work, gaps, quality issues |
| Task Review | Integration check | Cross-unit issues, coherence |
| Human Review | Final authority | Judgment calls, quality assessment |

**Key distinction:**
- **Confirmation** = "Do this task" (agent tries to complete, finds nothing to do)
- **Verification** = "Review this work" (agent explicitly critiques completed work)

Both are necessary. Confirmation catches work that isn't done. Verification catches work that's done but flawed.

## Checkpoint Types

When human interaction is needed, categorize by type to minimize unnecessary pauses:

| Type | Frequency | Use |
|------|-----------|-----|
| human-verify | ~90% | Claude automated, human confirms result |
| decision | ~9% | User chooses between approaches |
| human-action | ~1% | Truly unavoidable manual step |

**Principle:** If Claude can run it, Claude runs it. Always automate first. Set up verification environment (start servers, create test data) before presenting checkpoint.

### human-verify checkpoint

Most common. Claude completes the work, human confirms visual/functional correctness.

```
**Completed:** {what Claude built/automated}
**To verify:**
1. {specific step with URL/command}
2. {expected outcome}

Reply "approved" or describe issues.
```

### decision checkpoint

User makes architectural or design choices. Present options with context.

```
**Decision needed:** {what's being decided}
**Context:** {why this matters}

Options:
A. {option} - {pros} / {cons}
B. {option} - {pros} / {cons}

Reply with your choice.
```

### human-action checkpoint

Rare. Only for actions Claude cannot perform (external account auth, physical access, etc.).

```
**Manual step needed:** {what action}
**Why Claude can't:** {explanation of limitation}
**After completing:** {how to signal ready to continue}
```
