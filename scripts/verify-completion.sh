#!/bin/bash
# Verify iterative workflow is complete before allowing stop
# Used by Stop hook

ITERATIVE_DIR=".claude/iterative"

# Check for active work
if [ -d "$ITERATIVE_DIR" ]; then
  for dir in "$ITERATIVE_DIR"/*/; do
    [ -d "$dir" ] || continue
    [[ "$dir" == *"/archive/"* ]] && continue

    STATE_FILE="${dir}state.json"
    if [ -f "$STATE_FILE" ]; then
      PHASE=$(grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
      TASK=$(grep -o '"task"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

      if [ -n "$PHASE" ] && [ "$PHASE" != "complete" ]; then
        cat <<EOF
WARNING: Iterative workflow "$TASK" is still active (phase: $PHASE)

Before stopping, ensure:
- All tasks/phases have DONE signals in progress.md
- Verification has passed
- state.json phase is "complete"

State directory: $dir
EOF
        exit 0
      fi
    fi
  done
fi

# No active work found
exit 0
