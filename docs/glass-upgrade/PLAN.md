# Liquid Glass upgrade plan — Chakame

_Generated 2026-11-12. Min iOS 17.0. Latest SDK checked: iOS 27.2 (Xcode 27.2). Status: APPROVED, implementing on `feature/liquid-glass`._

## Summary
- Screens reviewed: 8 (✅ automatic: 3 · 🔧 fixes: 4 · 🔁 restructure: 1)
- Blockers: none. SwiftUI App lifecycle, no compatibility flag, no custom bars.
- Biggest risks:
  1. Poem reader's custom floating prev/next overlay: no material, covers content, LTR order.
  2. RTL applied below the navigation chrome, so tab bar and nav bars are LTR.
  3. Settings footer outside the Form, pinned over the floating tab bar.
- Biggest wins: system glass bottom toolbar in the reader, RTL-correct chrome, tab bar minimize on scroll, favorites empty state, favorite bounce and haptic, share poem.
- Unverified: iOS 17 fallback rendering (no iOS 17 simulator runtime installed). Reduce Transparency and large Dynamic Type not checked.

## Wave 0 — Blockers
None.

## Wave 1 — Foundation
- `Chakame/Utils/View+LiquidGlass.swift`: `#available(iOS 26)` shims (`minimizeTabBarOnScroll()`, `navigationSubtitleIfAvailable(_:)`, `minimizedSearchToolbar()`). No raw glass APIs in feature code. No GlassKit wrapper, because nothing draws custom glass.
- RTL once at the root (`ContentView`) instead of per screen.
- No global appearance cleanup needed. No snapshot setup (out of scope); visual check via simulator screenshots.

## Wave 2 — Feature areas
| Wave | Area | Screens | Main changes | Effort | Risk |
|---|---|---|---|---|---|
| 2 | Poem | PagePoemView, VersesView | Bottom-bar toolbar (RTL order), hide tab bar, favorite effect and haptic, ShareLink, subtitle, semantic row colors | M | low |
| 2 | Favorite | FavoriteView | Empty state | S | low |
| 2 | Setting | SettingView | NavigationStack, footer inside Form | S | low |
| 2 | Home / Category | CenturiesView, CategoryView | Minimized search (26), subtitle (26) | S | low |

## Opportunities backlog
See [OPPORTUNITIES.md](OPPORTUNITIES.md).

## Testing and rollout
- Automatic: `make lint test`, `make test-ui` (launch smoke test).
- Manual design QA: reader (both directions, first/last poem), Favorites empty and filled, Settings, light and dark, iOS 26.5 and 27.2.
- Everything ships with the SDK. No flags needed (no funnel screens).

## Open questions for design / product
1. Should Icon Composer layered icon work be scheduled? The legacy icon looks flat on iOS 26+ home screens.
2. Should the reader also support swipe paging between poems?

## Appendix
[areas/](areas/) · [audit-summary.md](audit-summary.md) · [screen-inventory.csv](screen-inventory.csv) · [OPPORTUNITIES.md](OPPORTUNITIES.md) · [00-project-facts.md](00-project-facts.md)
