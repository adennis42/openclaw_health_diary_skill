#!/bin/bash
# Creates today's health diary journal file from template.
# Usage: ./new-day.sh [journal-dir]
# Default journal dir: memory/health-diary (relative to workspace root)

JOURNAL_DIR="${1:-memory/health-diary}"
DATE=$(date +%Y-%m-%d)
DAY=$(date +"%A")
FORMATTED_DATE=$(date +"%B %-d, %Y")
OUTPUT_FILE="$JOURNAL_DIR/$DATE.md"

mkdir -p "$JOURNAL_DIR"

if [ -f "$OUTPUT_FILE" ]; then
  echo "Journal for $DATE already exists: $OUTPUT_FILE"
  exit 0
fi

cat > "$OUTPUT_FILE" << EOF
# Health Diary — $DAY, $FORMATTED_DATE

**Weight:** — lbs
**Daily Goal:** — cal
**Running Total:** 0 cal

---

## Food & Drink

| Time | Item | Est. Calories | Notes |
|------|------|---------------|-------|
| — | — | — | No entries yet |

---

## Workouts

| Time | Exercise | Sets × Reps | Weight | Notes |
|------|----------|-------------|--------|-------|
| — | — | — | — | No entries yet |

---

## Daily Summary

- **Total calories:** 0
- **Estimated protein:** —
- **Workouts:** 0
- **Check-ins:** 0/3

**Notes:**
EOF

echo "Created: $OUTPUT_FILE"
