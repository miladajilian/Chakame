# Poem reader

## Screens
| Screen | Stack | Presentation | Revenue-critical | Verdict |
|---|---|---|---|---|
| PagePoemView (+ VersesView) | SwiftUI | push (from Home and Favorite) | no | 🔁 |

## PagePoemView
**What happens automatically:** the favorite button gets a glass capsule in the nav bar.
**Breaks or fights the system:**
- `PagePoemView.swift:20-52`: previous/next are custom buttons in `.overlay(alignment: .bottom)` with `.opacity(0.4)`. They float over the verses without a material (illegible over text), cover the last verse (no safe-area inset), sit on top of the floating tab bar, and are in LTR order in an RTL app. The audit script missed this because it isn't named "FAB". Fix: move them to `ToolbarItemGroup(placement: .bottomBar)`, which gives system glass on 26+ and a classic toolbar on 17, with content insets handled. Hide the tab bar while reading. Severity: high.
- Order: with RTL, next goes on the left. Use `chevron.forward`/`chevron.backward`, which mirror automatically.
**Make it nicer:**
- Favorite: `.symbolEffect(.bounce, value:)` plus `.sensoryFeedback` (iOS 17).
- `ShareLink` with the poem text, next to favorite.
- On iOS 26+, a `navigationSubtitle` showing the position ("۳ از ۱۲").
**Effort:** M · **Risk:** low

## VersesView
**Breaks or fights the system:** `VersesView.swift:32`: `Color.gray.opacity(0.5)` rows look muddy in dark mode and under glass. Use semantic colors (`secondarySystemBackground`/`tertiarySystemBackground`). Severity: low.
**Effort:** S · **Risk:** low
