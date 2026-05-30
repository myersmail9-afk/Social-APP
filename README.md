# Offline 📵

A social screen-time app. Track your phone usage, break it down by category,
and share it with friends so you can motivate each other to put the phone down.

> Think "Strava for using your phone less." The accountability and friendly
> competition is the hook.

## What's here today

This is the **v0 scaffold** — a fully interactive SwiftUI app running on
realistic sample data, so you can see and feel the whole experience before
wiring up real tracking and a backend.

### Screens

| Tab | What it does |
| --- | --- |
| **You** | Today's usage ring vs. your daily goal, this week's trend chart, and a breakdown of where your time went by category. |
| **Friends** | A leaderboard of you + friends ranked by today's screen time. Tap anyone to see their full breakdown. Add friends by handle. |
| **Feed** | The social heartbeat — friends' streaks, wins, and shared summaries, with tap-to-cheer. |
| **Profile** | Your stats, an adjustable daily goal, the (stubbed) Screen Time connect button, and sharing/privacy toggles. |

### Categories

Usage is grouped into clean, generic buckets: Social, Entertainment,
Productivity, Music, Games, Health, Education, Other.

## Running it

You need a **Mac with Xcode 15+** (the Screen Time frameworks and iOS build
tooling are Apple-only).

```bash
./scripts/setup.sh        # installs XcodeGen, generates the project, opens Xcode
```

…then press ▶︎ to run in the iOS Simulator. Or manually:

```bash
brew install xcodegen
xcodegen generate
open Offline.xcodeproj
```

> The `.xcodeproj` is **generated** from [`project.yml`](project.yml) and is
> git-ignored. Edit `project.yml` (not the project file) to change build
> settings, then re-run `xcodegen generate`.

## Architecture

Everything the views need flows through a single `AppStore` (an `@Observable`),
which talks to a `DataService` **protocol**. Today that's `MockDataService`
(in-memory sample data). This is the seam that keeps the app backend-agnostic.

```
Offline/
├─ OfflineApp.swift          # @main entry, injects AppStore
├─ AppStore.swift            # @Observable app state (the only thing views read)
├─ Models/                   # UsageCategory, Usage, User, Activity
├─ Services/
│  ├─ DataService.swift      # protocol — the backend seam
│  ├─ MockDataService.swift  # in-memory implementation (current)
│  ├─ SampleData.swift       # realistic generated demo data
│  └─ ScreenTimeProvider.swift  # protocol for real usage tracking (stubbed)
├─ Theme/Theme.swift         # colors, card style, formatting helpers
└─ Views/                    # Dashboard, Friends, Feed, Profile + Components
```

### Why this shape

- **Swap the backend without touching UI.** Replace `MockDataService` with a
  Supabase/Firebase/CloudKit implementation of `DataService` and the whole app
  keeps working.
- **Swap the data source the same way.** Real device usage comes in behind
  `ScreenTimeProvider`.

## Roadmap — turning the scaffold real

### 1. Real Screen Time tracking (the core feature)
Implement `ScreenTimeProvider` with Apple's frameworks:
- `FamilyControls` — request authorization (`AuthorizationCenter`)
- `DeviceActivity` — schedule monitoring + a `DeviceActivityReport` extension
- `ManagedSettings` *(optional)* — enforce app limits/shields

⚠️ **Privacy constraint to design around:** Apple does **not** hand your app
raw per-app minutes to freely upload. Usage is surfaced inside a sandboxed
report extension; you compute category aggregates there and pass only the
totals to the main app (via an **App Group** shared container). You'll also
need to request the **Family Controls entitlement** from Apple.

### 2. Real backend (recommended: Supabase)
Implement `DataService` against a real backend for accounts, the friend graph,
and sharing. Suggested first tables: `profiles`, `friendships`,
`daily_usage`, `activities`. Supabase gives you Postgres + auth + row-level
security (so a user only shares what they opt into), with predictable pricing
and data you own — a sustainable long-term choice. Firebase or CloudKit are
fine alternatives; the `DataService` seam means the choice isn't locked in.

### 3. Polish & engagement
Push notifications for nudges/cheers, weekly recaps, badges/achievements,
challenges between friends, and a real app icon + onboarding.

## Status

- [x] Models, theme, mock data layer
- [x] Dashboard (ring, weekly chart, category breakdown)
- [x] Friends leaderboard + detail + add-by-handle
- [x] Social feed with cheers
- [x] Profile with goal slider & privacy toggles
- [ ] Real Screen Time integration (`ScreenTimeProvider`)
- [ ] Real backend (`DataService`)
- [ ] Auth & onboarding
- [ ] Notifications, badges, challenges
