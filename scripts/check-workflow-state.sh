#!/bin/bash
# Check if iterative workflow has active state
# Returns JSON for hook consumption

ITERATIVE_DIR=".claude/iterative"

# Find any active (non-archived) state
if [ -d "$ITERATIVE_DIR" ]; then
  for dir in "$ITERATIVE_DIR"/*/; do
    [ -d "$dir" ] || continue
    [[ "$dir" == *"/archive/"* ]] && continue

    STATE_FILE="${dir}state.json"
    if [ -f "$STATE_FILE" ]; then
      PHASE=$(grep -o '"phase"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')

      if [ -n "$PHASE" ] && [ "$PHASE" != "complete" ]; then
        TASK=$(grep -o '"task"[[:space:]]*:[[:space:]]*"[^"]*"' "$STATE_FILE" | head -1 | sed 's/.*"\([^"]*\)"$/\1/')
        echo "ACTIVE_ITERATIVE_WORK=true"
        echo "TASK=$TASK"
        echo "PHASE=$PHASE"
        echo "STATE_DIR=$dir"
        exit 0
      fi
    fi
  done
fi

echo "ACTIVE_ITERATIVE_WORK=false"
exit 0
