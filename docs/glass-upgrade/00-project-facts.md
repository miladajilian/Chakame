# Project facts — Chakame

_Collected 2026-11-12 for the Liquid Glass upgrade._

| Fact | Value |
|---|---|
| Deployment target | iOS 17.0 (all 6 build configurations) |
| Local Xcode | 27.2 (27B52), iOS SDK 27.2. Simulator runtimes: iOS 26.5, 27.2 (no iOS 17 runtime installed) |
| UI stack | 100% SwiftUI (12 SwiftUI files, 0 UIKit view controllers, 0 storyboards/xibs) |
| App lifecycle | SwiftUI `@main App` + `WindowGroup` → scene-based. **Not a blocker** for the iOS 27 SDK. |
| `UIDesignRequiresCompatibility` | Not set. The app already renders with Liquid Glass when built with Xcode 26+. |
| Global appearance | None (`UINavigationBar.appearance()`, `UITabBarAppearance`, `.toolbarBackground` all absent). |
| Design system | `Utils/Font.swift` (Vazirmatn custom fonts at Dynamic Type sizes). No shared colors or components. |
| RTL | The UI is Persian. `.environment(\.layoutDirection, .rightToLeft)` was set per screen, inside each `NavigationStack`, so the system chrome (tab bar, nav bars) stayed LTR. |
| Tests | Swift Testing unit tests and an XCUITest launch smoke test. No snapshot testing. |
| Feature flags | None. Not needed: no revenue or funnel screens. |
| Revenue-critical screens | None. |
| App icon | Legacy `AppIcon.appiconset`, no Icon Composer `.icon`. |

## APIs verified in the installed iOS 27.2 SDK
`glassEffect`, `GlassEffectContainer`, `.glassProminent`, `tabBarMinimizeBehavior` (`.onScrollDown`), `tabViewBottomAccessory`, `ToolbarSpacer`, `scrollEdgeEffectStyle`, `safeAreaBar`, `navigationSubtitle` (iOS 26 on iPhone), `searchToolbarBehavior` (`.minimize`), `backgroundExtensionEffect`, `ConcentricRectangle`, `TabRole`. All are iOS 26.0+.

## Not checked
Release notes for the newest SDK weren't fetched online. The guidance comes from the skill snapshot plus the installed SDK interfaces.
