# Linkezy

A dot-connect puzzle for [bgameworld.com](https://bgameworld.com). Join each pair of dots with a line, never cross another line, and cover every square.

- **Daily line:** one board a day, the same for everyone. It grows from 7×7 on Monday to 11×11 at the weekend. Solve it each day to keep your streak.
- **Levels:** 100 boards, from 5×5 up to 12×12. They're generated from a seed, so level 37 is the same for every player.
- Undo, restart, hints, a "Perfect" badge for one move per colour, letters on the dots for colour-blind players, and result sharing to WhatsApp and X.

The whole game is `index.html`, with no build step.

## Deploy

Connect this repo to Cloudflare Pages (no build command, output directory `/`) and add the custom domain `linkezy.bgameworld.com`. Share links already point there.

Set `LAUNCH_DATE` near the top of the script to your launch day, so that day becomes Daily line No. 1.

## Shared solver counts (optional)

1. Open Supabase, go to SQL editor, and run `supabase.sql`.
2. In `index.html`, set `SUPABASE_URL` and `SUPABASE_ANON_KEY` (Project Settings → API).

This shows "N players have solved today's line" and "faster than X% of solvers". Until it's set up, those numbers stay hidden. The game never makes them up.

## Tuning

`LEVEL_COUNT`, `levelSize()`, and `DAILY_SIZE` (board size by weekday) are all at the top of the script.
