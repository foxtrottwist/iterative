# Iteration Prompts

Minimal prompts for fresh-context iterations. Each iteration reads files for context—prompts provide orientation only.

## Core Principle

Every iteration is completely fresh. The prompt tells it:
- What task/phase and iteration
- Where to read state (not the state itself)
- What signal to emit when done

**Never include**: Previous iteration output, full brief, other task/phase details.

## Development Mode Prompts

### Implementation Prompt (Standard)

```
Iteration {I} of {MAX} for T{N}: "{title}"

Read these files first (your only memory):
- .claude/iterative/{slug}/progress.md
- .claude/iterative/{slug}/guardrails.md
- .claude/iterative/{slug}/context.md

Task: {title}
Files: {file_paths}
Criteria: {acceptance}

This iteration:
1. Read progress.md — find most recent T{N} entry
2. Continue from "Remaining" items
3. Make progress toward criteria
4. Commit: "feat({slug}): {summary}"
5. Append to progress.md:

## T{N} - Iteration {I} - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left, or "None"}
**Blockers:** {issues, or "None"}
**Commit:** {hash}

If ALL criteria met:
- Add "**Signal:** T{N}_DONE"
- Output: <signal>T{N}_DONE</signal>

If blocked:
- Add blocker details
- Output: <signal>BLOCKED:{reason}</signal>
```

### First Iteration Variant (Dev)

```
Iteration 1 of {MAX} for T{N}: "{title}"

Read these files first:
- .claude/iterative/{slug}/guardrails.md (lessons from other tasks)
- .claude/iterative/{slug}/context.md (feature overview)

Task: {title}
Files: {file_paths}
Criteria: {acceptance}

This is the first iteration. Start fresh:
1. Understand the task requirements
2. Plan your approach
3. Begin implementation
4. Commit meaningful progress: "feat({slug}): {summary}"
5. Append to progress.md:

## T{N} - Iteration 1 - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left}
**Blockers:** {issues, or "None"}
**Commit:** {hash}

If you complete everything in one iteration:
- Add "**Signal:** T{N}_DONE"
- Output: <signal>T{N}_DONE</signal>
```

### Test Prompt

```
Test iteration {I} for "{feature}".

Read:
- .claude/iterative/{slug}/progress.md (implementation details)
- .claude/iterative/{slug}/tasks.md (what to test)
- Existing test patterns in project

Files needing tests: {list}

Requirements:
1. Follow existing test patterns exactly
2. Cover each acceptance criterion
3. Include edge cases from progress.md
4. Test error states

Append to progress.md:

## Tests - Iteration {I} - {timestamp}
**Files:** {test files created/modified}
**Coverage:** {what is tested}
**Result:** PASS or FAIL
**Commit:** {hash}

If all tests pass:
- Output: <signal>TESTS_PASS</signal>

If tests fail:
- List failures
- Output: <signal>TESTS_FAIL:{summary}</signal>
```

### Fix Prompt

```
Fix iteration {I} for issue in "{feature}".

Read:
- .claude/iterative/{slug}/guardrails.md
- .claude/iterative/{slug}/progress.md (find the review that identified this)

Issue to fix:
- File: {path}
- Line: {number}
- Problem: {description}
- Severity: {error|warning}

Fix the issue:
1. Locate the problem
2. Implement minimal fix
3. Verify the fix works
4. Commit: "fix({slug}): {summary}"

Append to progress.md:

## Fix - Iteration {I} - {timestamp}
**Issue:** {description}
**File:** {path}:{line}
**Fix:** {what you changed}
**Commit:** {hash}

If fix requires broader changes:
- Output: <signal>NEEDS_ESCALATION:{reason}</signal>

If fixed:
- Output: <signal>FIXED</signal>

Add guardrail if this reveals a pattern to avoid.
```

## Knowledge Mode Prompts

### Phase Prompt (Standard)

```
Iteration {I} of {MAX} for {phase}: "{title}"

Read these files first (your only memory):
- .claude/iterative/{slug}/progress.md
- .claude/iterative/{slug}/guardrails.md
- .claude/iterative/{slug}/context.md

Phase: {phase}
Criteria: {acceptance}
Output: {output_path}

This iteration:
1. Read progress.md — find most recent {phase} entry
2. See what "Remaining" items exist
3. Continue from where last iteration stopped
4. Save work to output path
5. Append to progress.md:

## {phase} - Iteration {I} - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left, or "None"}
**Blockers:** {issues, or "None"}

6. If ALL criteria met:
   - Add "**Signal:** {phase}_DONE"

7. If blocked:
   - Add lesson to guardrails.md
   - Note blocker for user input

8. If not done, just exit. Next iteration continues.
```

### First Iteration Variant (Knowledge)

```
Iteration 1 of {MAX} for {phase}: "{title}"

Read these files first:
- .claude/iterative/{slug}/guardrails.md (lessons from prior phases)
- .claude/iterative/{slug}/context.md (task overview)

Phase: {phase}
Criteria: {acceptance}
Output: {output_path}

This is the first iteration. Start fresh:
1. Understand the phase requirements
2. Plan your approach
3. Begin work
4. Save progress to output path
5. Append to progress.md:

## {phase} - Iteration 1 - {timestamp}
**Did:** {what accomplished}
**Remaining:** {what's left}
**Blockers:** {issues, or "None"}

If you complete everything in one iteration:
- Add "**Signal:** {phase}_DONE"
```

### Revise Prompt

```
Revise iteration {I} for issue in "{task}".

Read:
- .claude/iterative/{slug}/guardrails.md
- .claude/iterative/{slug}/progress.md

Issue to fix:
- Output: {path}
- Type: {gap|quality|accuracy}
- Problem: {description}

Fix the issue:
1. Locate the problem
2. Implement targeted fix
3. Verify fix works
4. Append to progress.md:

## Revise - Iteration {I} - {timestamp}
**Issue:** {description}
**Output:** {path}
**Fix:** {what changed}

If fixed:
- Add "**Result:** FIXED"

If broader changes needed:
- Add "**Result:** NEEDS_ESCALATION"

Add guardrail if this reveals pattern to avoid.
```

## Common Prompts (Both Modes)

### Mandatory Confirmation Pass (N+1)

After an agent declares DONE, spawn a fresh agent with the **exact same prompt** as the first iteration. This agent doesn't know it's a "confirmation" — it just tries to complete the task/phase.

**Critical:** Use the First Iteration Variant prompt. Do NOT use a special "confirmation" prompt.

What happens:
- If work is truly complete → Agent finds nothing to do → Declares DONE
- If work is incomplete → Agent naturally completes it → May iterate

**Why this works:** Two independent agents, same mandate, both concluding done = consensus.

### Review Prompt

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

If ALL checks pass:
- Add "**Signal:** REVIEW_PASS"

If issues found, list each:
[gap] {output/file} - {description}
[quality] {output/file} - {description}

Then add: **Signal:** REVIEW_FAIL

Append to progress.md:

## Review - Iteration {I} - {timestamp}
**Checked:** {units reviewed}
**Result:** PASS or FAIL
**Issues:** {list or "None"}
```

## Signal Reference

| Signal | Meaning | Next Action |
|--------|---------|-------------|
| `T{N}_DONE` | Task complete | Run confirmation pass |
| `{phase}_DONE` | Phase complete | Run confirmation pass |
| `T{N}_VERIFIED` | Verification passed | Mark task complete |
| `{phase}_VERIFIED` | Verification passed | Mark phase complete |
| `BLOCKED:{reason}` | Cannot proceed | Ask user for input |
| `REVIEW_PASS` | All checks pass | Move to deliver |
| `REVIEW_FAIL` | Issues found | Dispatch fix/revise loops |
| `FIXED` | Issue resolved | Re-run verification/review |
| `TESTS_PASS` | Tests green | Continue |
| `TESTS_FAIL:{summary}` | Tests red | Fix or escalate |
| `NEEDS_ESCALATION:{reason}` | Beyond scope | Ask user |

## Prompt Size Target

Each prompt under 500 tokens. Work happens in file reading.

| Component | Max Tokens |
|-----------|------------|
| Task/phase description | 50 |
| File paths | 50 |
| Criteria | 100 |
| Instructions | 200 |
| Format template | 100 |

## What NOT to Include

Never put these in iteration prompts:
- Previous iteration's output
- Full brief/PRD content
- Other task/phase details
- Code snippets from prior work
- Conversation history
- File contents (give paths, let agent read)

The agent reads files. The prompt just points to them.
