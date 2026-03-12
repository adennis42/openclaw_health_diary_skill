---
name: health-diary
description: Daily food and workout tracking with calorie estimation, restaurant lookups, and progress logging. Use when a user wants to: log meals or drinks, estimate calories, track workouts (sets/reps/weight), log disc golf or other activity, get a daily calorie total, set up daily check-in reminders, or review weekly/bi-weekly health summaries. Activates on phrases like "I ate", "I had", "I drank", "I worked out", "I lifted", "log my meal", "how are my calories", "start tracking", or any food/fitness diary request.
---

# Health Diary Skill

Structured daily logging for food intake, calorie estimation, and workout tracking.

## Setup (First Run)

When a user sets up the skill for the first time:

1. Ask for their **location** (city/region) for restaurant calorie lookups
2. Ask for their **current weight** (optional but helpful for calorie targets)
3. Ask their **goal** (weight loss, maintenance, muscle gain)
4. Run `scripts/new-day.sh` to create today's journal file
5. Optionally set up cron check-ins — see **Cron Setup** below

Save to `MEMORY.md`:
- Location, current weight, goal, any medications relevant to appetite (e.g. GLP-1s like Zepbound/Ozempic)

## Daily Journal Files

- Location: `memory/health-diary/YYYY-MM-DD.md`
- Create with: `scripts/new-day.sh` (auto-names with today's date)
- One file per day. Append entries throughout the day.

See `assets/daily-template.md` for the file format.

## Logging Food

When a user reports eating or drinking something:

1. Estimate calories using `references/calorie-reference.md` as a guide
2. If a restaurant is mentioned, search for their menu/nutrition info online
3. Append the entry to today's journal file
4. Report back: item, estimated calories, running daily total
5. Note any observations (small portion = appetite suppression working, etc.)

**Estimation principles:**
- Be honest that these are approximations, not exact
- For restaurant items, look up nutrition data when possible
- For homemade food, estimate by ingredient
- For partial portions, scale accordingly (e.g. "6 fries" ≈ ~50 cal)
- Beverages count — especially sweetened drinks, protein shakes, alcohol

## Logging Workouts

When a user reports a workout:

1. Append to today's journal under the `## Workouts` section
2. Log: exercise name, sets × reps, weight used, any notes
3. For cardio/activity (disc golf, walking, etc.): log duration and estimate calories burned
4. Over time, track PRs (personal records) in `memory/health-diary/prs.md`

See `references/workout-logging.md` for logging format and calorie burn estimates.

## Calorie Targets

Use these rough daily targets based on goal (adjust for body size):

| Goal | Daily Calories |
|------|---------------|
| Aggressive weight loss (2 lb/week) | TDEE − 1,000 |
| Moderate weight loss (1 lb/week) | TDEE − 500 |
| Maintenance | TDEE |
| Muscle gain | TDEE + 300 |

TDEE estimate for sedentary large-framed individual (~325 lbs): ~2,800–3,200 cal/day.
Adjust based on activity level and user feedback over time.

## Cron Setup

To set up automatic daily check-ins, run these three commands (adjust timezone as needed):

```bash
# Morning (10am)
openclaw cron add --name "health-diary-morning" --cron "0 10 * * *" --tz "America/New_York" --announce --channel telegram --to "<CHAT_ID>" --message "🍽️ Morning check-in! What have you had to eat or drink so far today?"

# Lunch (1pm)
openclaw cron add --name "health-diary-lunch" --cron "0 13 * * *" --tz "America/New_York" --announce --channel telegram --to "<CHAT_ID>" --message "🥗 Lunch check-in! What have you eaten since this morning?"

# Evening (9pm)
openclaw cron add --name "health-diary-evening" --cron "0 21 * * *" --tz "America/New_York" --announce --channel telegram --to "<CHAT_ID>" --message "🌙 Evening check-in! What did you eat for dinner or any snacks? I'll wrap up your daily total."
```

For bi-weekly summaries (1st and 15th at 9am):
```bash
openclaw cron add --name "health-diary-biweekly" --cron "0 9 1,15 * *" --tz "America/New_York" --announce --channel telegram --to "<CHAT_ID>" --message "📊 Bi-weekly health summary! Read memory/health-diary/ files from the past 14 days and send a summary: avg daily calories, highest/lowest days, most common foods, workout frequency, and any patterns worth noting."
```

## Weekly / Bi-Weekly Reviews

When generating a summary, read the past 7–14 daily journal files and report:
- Average daily calories
- Highest and lowest calorie days
- Most frequently eaten foods and drinks
- Workout sessions completed
- Notable patterns (skipped meals, late eating, high-calorie days)
- Weight change if logged
- Encouragement based on consistency
