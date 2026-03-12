---
name: health-diary
description: Daily food and workout tracking with calorie estimation, restaurant lookups, and progress logging. Use when a user wants to: log meals or drinks, estimate calories, track workouts (sets/reps/weight), log disc golf or other activity, get a daily calorie total, set up daily check-in reminders, or review weekly/bi-weekly health summaries. Also triggers on first-time setup phrases like "set up health diary", "start tracking my food", "I want to track what I eat", or "start a food journal". Activates on phrases like "I ate", "I had", "I drank", "I worked out", "I lifted", "log my meal", "how are my calories", or any food/fitness diary request.
---

# Health Diary Skill

Structured daily logging for food intake, calorie estimation, and workout tracking.

## First-Time Setup

When a user sets up the skill for the first time (no existing journal files), run through the onboarding flow. Ask these questions **one or two at a time** — do not dump them all at once:

**Round 1:**
- What's your name? (for personalized responses)
- What's your general location? (city/region — used for restaurant menu lookups)

**Round 2:**
- What's your current weight? (optional — helps calculate calorie targets)
- Do you have a goal weight in mind?

**Round 3:**
- What's your main goal? (weight loss / maintenance / muscle gain)
- Are you on any appetite-affecting medications? (e.g. Zepbound, Ozempic, Wegovy — affects calorie target recommendations)

**Round 4:**
- Would you like daily check-in reminders via Telegram? (3x/day: morning, lunch, evening)
  - If yes: ask for their Telegram chat ID and preferred times (defaults: 10am, 1pm, 9pm)
  - If yes: ask their timezone
- Would you like a bi-weekly summary? (1st and 15th of each month)

After onboarding:
1. Save all answers to `MEMORY.md` under a `## Health Diary` section
2. Run `scripts/new-day.sh` to create today's journal
3. Create `memory/health-diary/prs.md` for workout PRs (empty table)
4. Set up cron jobs if requested — see **Cron Setup** section
5. Confirm setup complete and invite first food/workout log entry

## Daily Journal Files

- Location: `memory/health-diary/YYYY-MM-DD.md`
- Create with: `scripts/new-day.sh`
- One file per day — append entries throughout the day
- See `assets/daily-template.md` for format

## Logging Food

When a user reports eating or drinking:

1. **Look up the restaurant first** if one is mentioned — see **Restaurant Lookup** below
2. Estimate calories using `references/calorie-reference.md` as a fallback
3. Append the entry to today's journal
4. Reply with: item logged, estimated calories, running daily total
5. Note observations naturally (small portion, skipped a meal, etc.)

**Estimation principles:**
- Be clear these are approximations, not exact figures — this is a diary, not a clinical tracker
- Scale partial portions (e.g. "6 fries" ≈ ~50 cal, "half a sandwich" = half the calories)
- Beverages always count — sweetened drinks add up fast
- When unsure, err slightly high rather than low

## Restaurant Lookup (Web Search)

When a user mentions a restaurant by name, **always attempt a web lookup** before falling back to estimates:

**Step 1 — Try the restaurant's nutrition page directly:**
```
https://www.{restaurant-slug}.com/nutrition
https://www.{restaurant-slug}.com/menu
```

**Step 2 — If that fails, search a calorie database:**
Try fetching:
```
https://www.calorieking.com/us/en/foods/search?keywords={restaurant}+{item}
https://www.nutritionix.com/food/{item}
```

**Step 3 — General web search fallback:**
Search for: `"{restaurant name}" "{menu item}" calories nutrition`

Use the user's location to confirm the right restaurant chain when there are multiple possibilities (e.g. "Friendly's" is a regional diner chain in the Northeast US).
See `references/restaurants.md` for known nutrition URLs and regional chains (especially Northeast US).

**If lookup succeeds:** use the actual nutrition data, note the source
**If lookup fails (blocked/no data):** use `references/calorie-reference.md` estimates and note it's an approximation

## Logging Workouts

When a user reports a workout:

1. Append to today's journal under `## Workouts`
2. Log: exercise name, sets × reps, weight used, notes
3. For activity (disc golf, walking, etc.): log duration and estimate calories burned
4. Check `memory/health-diary/prs.md` — if a new PR was hit, call it out and update the file

See `references/workout-logging.md` for format and calorie burn estimates.

## Calorie Targets

| Goal | Daily Calories |
|------|---------------|
| Aggressive weight loss (~2 lb/week) | TDEE − 1,000 |
| Moderate weight loss (~1 lb/week) | TDEE − 500 |
| Maintenance | TDEE |
| Muscle gain | TDEE + 300 |

Rough TDEE for a sedentary large-framed individual (~300–350 lbs): ~2,800–3,200 cal/day.
For GLP-1 users (Zepbound/Ozempic/Wegovy): natural appetite suppression usually puts intake well below target — this is expected and fine. Focus on protein (aim for 0.7–1g per lb of goal body weight).

## Cron Setup

Run these commands to set up Telegram check-ins (replace `<CHAT_ID>` and adjust timezone/times per user preference):

```bash
# Morning check-in
openclaw cron add --name "health-diary-morning" --cron "0 10 * * *" --tz "<TIMEZONE>" --announce --channel telegram --to "<CHAT_ID>" --message "🍽️ Morning check-in! What have you had to eat or drink so far today? Reply and I'll log it with calorie estimates."

# Lunch check-in
openclaw cron add --name "health-diary-lunch" --cron "0 13 * * *" --tz "<TIMEZONE>" --announce --channel telegram --to "<CHAT_ID>" --message "🥗 Lunch check-in! What have you eaten since this morning? I'll add it to your food log."

# Evening check-in
openclaw cron add --name "health-diary-evening" --cron "0 21 * * *" --tz "<TIMEZONE>" --announce --channel telegram --to "<CHAT_ID>" --message "🌙 Evening check-in! What did you eat for dinner or any snacks? I'll wrap up your daily total."

# Bi-weekly summary (optional)
openclaw cron add --name "health-diary-biweekly" --cron "0 9 1,15 * *" --tz "<TIMEZONE>" --announce --channel telegram --to "<CHAT_ID>" --message "📊 Bi-weekly health summary! Read memory/health-diary/ files from the past 14 days and send a summary: avg daily calories, highest/lowest days, most common foods, workout frequency, and any patterns worth noting."
```

## Weekly / Bi-Weekly Reviews

Read the past 7–14 daily journal files and report:
- Average daily calories
- Highest and lowest calorie days
- Most frequently eaten foods and drinks
- Workout sessions logged
- Notable patterns (skipped meals, late eating, beverage calories)
- Weight change if logged
- Positive reinforcement based on consistency and progress
