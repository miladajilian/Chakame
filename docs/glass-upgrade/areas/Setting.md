# Setting

## Screens
| Screen | Stack | Presentation | Revenue-critical | Verdict |
|---|---|---|---|---|
| SettingView | SwiftUI | tab root | no | 🔧 |

## SettingView
**What happens automatically:** the Form gets the new grouped look and the larger toggle.
**Breaks or fights the system:**
- `SettingView.swift:15`: deprecated `NavigationView`. Use `NavigationStack`.
- `SettingView.swift:16-36`: `VStack { Form; Spacer; about; version }` puts the footer outside the scroll view. It's pinned above the floating tab bar, and the Form can't scroll edge to edge. Move about/version into a `Section` footer. Severity: medium.
- `:25`: `.foregroundColor(.gray)` → `.foregroundStyle(.secondary)`.
- L02: the iOS 26 toggle is wider, so check that the Persian label doesn't clip.
**Effort:** S · **Risk:** low
