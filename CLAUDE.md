# Chakame

SwiftUI iOS app for reading Persian poetry from the [Ganjoor API](https://api.ganjoor.net), cached locally in Core Data.
Single Xcode project (`Chakame.xcodeproj`), one SPM dependency (Nuke / `NukeUI` for poet images).

## Commands

```bash
make build      # build for an iPhone simulator
make test       # unit tests (ChakameTests); results in build/TestResults.xcresult
make test-ui    # UI smoke tests (ChakameUITests)
make lint       # SwiftLint --strict (must be clean)
make format     # SwiftFormat (config in .swiftformat)
```

The simulator is picked by `scripts/sim-destination.sh` (a booted iPhone, else the newest one). Override with `SIM="iPhone 17"` or `SIM_ID=<udid>`.
**Before you finish any code change, run `make lint test`.**

## Project layout

The project uses **synchronized folders**: create, move or delete files on disk and Xcode picks them up. Never hand-edit `project.pbxproj` to add files.

```
Chakame/
  ChakameApp.swift, ContentView.swift   # entry point + TabView (Home / Favorite / Setting)
  <Feature>/                            # Centuries, Category, Poem, Favorite, Setting
    Views/  ViewModels/  Services/
  Core/Data/api/                        # networking: RequestProtocol, RequestType, APIManager, RequestManager, DataParser
  Core/Data/coreData/                   # PersistenceController, CoreDataHelper, Chakame.xcdatamodeld, *+CoreData.swift mappings
  Core/Domain/model/<type>/             # Decodable structs (Century, Poet, Category, Poem, Verse) + *Container + *Mock
  Utils/                                # Constants (API host, UserDefaults keys), Font
  Resources/                            # Info.plist, Localizable.xcstrings, Vazirmatn font
  Preview Content/                      # *Mock.json used by previews and mocks
ChakameTests/Tests/<mirrors app path>/  # unit tests; API mocks in Tests/Core/Data/api/mock
ChakameUITests/                         # launch smoke test
```

## Architecture conventions

- **MVVM per feature.** Views are SwiftUI. View models are `@MainActor final class …: ObservableObject` using async/await.
- **Services behind protocols.** Each view model declares its `…Fetcher` / `…Store` protocols, takes them through `init` with production defaults, and gets a `…Mock` for previews and tests. Follow `Centuries/` as the reference feature.
- **Networking.** Add an endpoint as a `RequestProtocol` type under `Core/Data/api/request/`, and decode with `DataParser` into a domain struct.
- **Persistence (Core Data).**
  - API data is cached; the only user-owned data is `PoemEntity.isFavorite`.
  - Entity classes (`*Entity`) are **auto-generated** from `Chakame.xcdatamodeld` (`codeGenerationType="class"`), so don't write them by hand.
  - Struct ↔ entity mapping lives in `Core/Data/coreData/extensions/<Type>+CoreData.swift`.
  - Writes use `performBackgroundTask`. Views read through `@FetchRequest`.
  - **Planned:** this layer is going to be migrated to SwiftData. Keep new persistence code thin and isolated.
- **Previews** use `PersistenceController.preview` (in-memory) and the `CoreDataHelper.getTest*` helpers.

## Rules

- No `fatalError`, `try!` or force-unwraps in new code. Throw or surface errors to the view model.
- Avoid adding more uses of `PersistenceController.shared`. Inject dependencies through `init` instead.
- Every user-facing string goes in `Resources/Localizable.xcstrings`. See the gotchas below.
- New logic in a view model or service gets a unit test in `ChakameTests/Tests/<Feature>/`, using mocks and the in-memory store. There are no network calls in tests.
- Keep files small and per type, and match the existing folder for each layer.
- SwiftLint also runs as an Xcode build phase, so lint violations show up in builds.

## Gotchas

- **Localization.** Keys are English (`"Home"`), but the **`en` values are Persian** (`"خانه"`). The UI is Persian and RTL, so UI tests must not match on English labels.
- **Deployment targets.** The app targets iOS 15.0, but the test targets need iOS 17.0 because the current XCTest requires it.
- **UI tests** run with parallel testing turned off in the shared scheme, because the test runner fails to launch on cloned simulators.
- **Settings.** The `alwaysOn` setting (`Constants.UserDefaultsKeys.alwaysOn`) toggles `UIApplication.shared.isIdleTimerDisabled`.
- **Font.** Poem text uses the bundled Vazirmatn font (`Utils/Font.swift`).
