# App shell (root TabView)

## Screens
| Screen | Stack | Presentation | Revenue-critical | Verdict |
|---|---|---|---|---|
| ContentView (TabView: Home / Favorite / Setting) | SwiftUI | root | no | 🔧 |
| StoreUnavailableView | SwiftUI | root (error) | no | ✅ |

## ContentView
**What happens automatically:** the tab bar becomes a floating glass capsule.
**Breaks or fights the system:**
- `ContentView.swift:15`, plus every feature view: RTL is applied per screen *inside* the `NavigationStack`, so the glass tab bar, nav bars, back chevron and push direction stay LTR while the content is RTL. Fix: apply `.environment(\.layoutDirection, .rightToLeft)` once at the root and remove the per-screen copies. Severity: medium.
**Make it nicer:** `.tabBarMinimizeBehavior(.onScrollDown)` (iOS 26+). The poet and verse lists are long, so give them the space.
**New possibilities:** a search tab (`Tab(role: .search)`) needs the iOS 18 `Tab` API. Backlog.
**Effort:** S · **Risk:** low

## StoreUnavailableView
`ContentUnavailableView` is fine as is.
