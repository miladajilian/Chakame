# Centuries (Home tab)

## Screens
| Screen | Stack | Presentation | Revenue-critical | Verdict |
|---|---|---|---|---|
| CenturiesView (+ PoetSearchResults, PoetRow) | SwiftUI | tab root | no | ✅ |

## CenturiesView
**What happens automatically:** the large title is transparent over the list, the search field is glass, and section headers scroll under the bar.
**Breaks or fights the system:** none.
**Make it nicer:**
- `CenturiesView.swift:42`: `.searchToolbarBehavior(.minimize)` (iOS 26+) folds search into a compact glass button, so the list keeps more of the screen.
- Remove the local RTL env (`:58`) once it's at the root.
**New possibilities:** none for now. Zoom transitions from poet to category need iOS 18.
**Effort:** S · **Risk:** low

## PoetRow
`PoetRow.swift:27` uses an 8 pt radius on a 50 pt thumbnail. This is content, not nested in a glass container. No change.
