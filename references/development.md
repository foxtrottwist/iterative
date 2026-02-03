# Development Mode

Task format, model selection, and programmatic gates for development work.

## Task Format

```markdown
# {Feature} - Tasks

**Created:** {timestamp}
**Total:** {N} tasks
**Status:** {X} done, {Y} in progress, {Z} pending

## Dependencies

```
T1 ──► T3 ──► T5
T2 ────┘
T4 (independent)
```

## Tasks

- [ ] **T1**: {title}
  - Files: `path/to/file.ts`
  - Criteria: {measurable acceptance}
  - Completion: `<signal>T1_DONE</signal>`
  - Max iterations: 5
  - Depends: none
  - Model: sonnet

- [ ] **T2**: {title}
  - Files: `path/to/file.ts`, `path/to/other.ts`
  - Criteria: {acceptance}
  - Completion: `<signal>T2_DONE</signal>`
  - Max iterations: 8
  - Depends: T1
  - Model: sonnet

## Notes

{Context for sub-agents}
```

## Field Definitions

| Field | Purpose |
|-------|---------|
| Title | Clear, action-oriented description |
| Files | Paths the task will modify |
| Criteria | Measurable acceptance conditions |
| Completion | Signal to emit when done |
| Max iterations | Safety limit for the iteration loop |
| Depends | Task dependencies (or "none") |
| Model | haiku, sonnet, or opus |

## Max Iterations Guide

| Task Complexity | Max Iterations | Signals |
|-----------------|----------------|---------|
| Simple | 3-5 | Single file, clear pattern, <50 lines |
| Medium | 5-10 | 2-3 files, moderate logic, some unknowns |
| Complex | 10-15 | Multiple files, new patterns, research needed |
| Exploratory | 15-20 | Unclear scope, may need multiple approaches |

**Rule**: Start conservative. You can always increase if a task times out.

## Model Selection

| Task Type | Model | Rationale |
|-----------|-------|-----------|
| File search, grep, glob | haiku | Pattern matching |
| Simple file edits (<50 lines) | haiku | Mechanical changes |
| Standard implementation | sonnet | Balanced capability |
| Code review | sonnet | Standards verification |
| Test generation | sonnet | Structured output |
| Complex debugging | opus | Root cause analysis |
| Architecture decisions | opus | Multi-factor reasoning |
| Refactors touching many files | opus | Coordination complexity |

**Default**: sonnet (best balance of capability and cost)

## Programmatic Gates

Run these checks after every completion attempt:

```bash
# Type checking (language-dependent)
tsc --noEmit                    # TypeScript
swift build                     # Swift
cargo check                     # Rust

# Linting
eslint {files}                  # JS/TS
swiftlint lint {files}          # Swift

# Tests
npm test -- --related {files}   # Jest
swift test --filter {module}    # Swift
```

If programmatic checks fail → back to implementation loop immediately.

## Test Gate

```
Implementation DONE → Build passes? → Test agent
                                        ├── Generate tests (if needed)
                                        ├── Run all tests
                                        ├── TESTS_PASS → Confirmation
                                        └── TESTS_FAIL → Fix iteration → Re-test
```

**Test strategy by task type:**

| Task Type | Test Approach |
|-----------|---------------|
| New feature | Unit + integration tests |
| Bug fix | Regression test for the bug |
| Refactor | Existing tests must pass |
| API change | Contract tests |

## Good vs Bad Tasks

### Good Task

```markdown
- [ ] **T1**: Create User data model
  - Files: `src/models/User.swift`
  - Criteria:
    - Model with id (UUID), email (String), createdAt (Date)
    - SwiftData @Model annotation
    - @Attribute(.unique) on email
  - Completion: `<signal>T1_DONE</signal>`
  - Max iterations: 5
  - Depends: none
  - Model: sonnet
```

Why it's good:
- Clear, specific title
- Single file focus
- Measurable criteria (can verify each point)
- Reasonable iteration limit
- Appropriate model

### Bad Task

```markdown
- [ ] **T1**: Implement authentication
  - Files: multiple
  - Criteria: users can log in
  - Completion: `<signal>T1_DONE</signal>`
  - Max iterations: 3
  - Depends: none
  - Model: haiku
```

Problems:
- Too broad ("implement authentication")
- Vague files ("multiple")
- Unmeasurable criteria ("users can log in")
- Too few iterations for complexity
- Wrong model (haiku for complex work)

## Status Annotations

As tasks complete, update the checkbox and add notes:

```markdown
- [x] **T1**: Create User model <!-- DONE: 3 iterations -->
- [ ] **T2**: Create AuthService <!-- IN_PROGRESS: iteration 4 -->
- [ ] **T3**: Create LoginView <!-- BLOCKED: Waiting on T2 -->
- [ ] **T4**: Add tests <!-- PENDING -->
```

## Dependency Notation

- `none` — Can start immediately
- `T1` — Wait for T1's loop to complete
- `T1, T2` — Wait for both (all must complete)

## Parallel Execution

Tasks without dependencies can run concurrent loops:

```
Launch parallel task loops:

T2 Loop: max 5 iterations [model: sonnet]
T4 Loop: max 3 iterations [model: haiku]

Each task runs its own iteration cycle independently.
```

## Implementation Agents

### Haiku (Simple Tasks)

- Single file changes under 50 lines
- Clear pattern to follow
- Mechanical transformations
- Simple grep/find operations

### Sonnet (Standard Tasks)

- 2-3 file changes
- Moderate complexity logic
- Following established patterns
- New components following existing architecture

### Opus (Complex Tasks)

- Complex debugging with unclear root cause
- Architectural decisions affecting multiple components
- Refactors touching many interconnected files
- Security-sensitive implementations
- Novel patterns not established in codebase
