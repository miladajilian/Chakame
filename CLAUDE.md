# Chakame

SwiftUI iOS app for reading Persian poetry from the [Ganjoor API](https://api.ganjoor.net), cached locally in SwiftData.
Single Xcode project (`Chakame.xcodeproj`), one SPM dependency (Nuke / `NukeUI` for poet images).

## Commands

```bash
make build      # build for an iPhone simulator
make test       # unit tests (ChakameTests); results in build/TestResults.xcresult
make test-ui    # UI smoke tests (ChakameUITests)
make test-all   # unit + UI tests
make lint       # SwiftLint --strict (must be clean)
make format     # SwiftFormat (config in .swiftformat)
make format-check  # verify formatting without changing files
```

The simulator is picked by `scripts/sim-destination.sh` (a booted iPhone, else the newest one). Override with `SIM="iPhone 17"` or `SIM_ID=<udid>`.
**Before you finish any code change, run `make lint test`.**

## Project layout

The project uses **synchronized folders**: create, move or delete files on disk and Xcode picks them up. Never hand-edit `project.pbxproj` to add files.

```
Chakame/
  ChakameApp.swift, ContentView.swift   # entry point (creates the ModelContainer) + TabView (Home / Favorite / Setting)
  AppDependencies.swift                 # builds store services + view models from the container
  <Feature>/                            # Centuries, Category, Poem, Favorite, Setting
    Views/  ViewModels/  Services/
  Core/Data/api/                        # networking: RequestProtocol, RequestType, APIManager, RequestManager, DataParser
  Core/Data/swiftData/                  # models/*Entity, ChakameSchemaV1, ChakameMigrationPlan, ModelContainerFactory, PreviewContainer
  Core/Data/swiftData/extensions/       # <Type>+SwiftData.swift upserts (domain struct → @Model)
  Core/Domain/model/<type>/             # Decodable structs (Century, Poet, Category, Poem, Verse) + *Container + *Mock
  Utils/                                # Constants (API host, UserDefaults keys), Font
  Resources/                            # Info.plist, Localizable.xcstrings, Vazirmatn font
  Preview Content/                      # *Mock.json used by previews and mocks
ChakameTests/Tests/<mirrors app path>/  # unit tests; API mocks in Tests/Core/Data/api/mock
ChakameUITests/                         # launch smoke test
```

## Architecture conventions

- **MVVM per feature.** Views are SwiftUI. View models are `@Observable @MainActor final class …` using async/await. Views own them with `@State`, or receive them as a plain `let` or through `.environment(_:)`.
- **Services behind protocols.** Each view model declares its `…Fetcher` / `…Store` protocols, takes them through `init`, and gets a `…Mock` for previews and tests. Fetchers have production defaults. Stores need a `ModelContext`, so `AppDependencies` builds them. Follow `Centuries/` as the reference feature.
- **Navigation.** Each tab has its own `NavigationStack`. Links push values (`CategoryRoute`, `PoemRoute`), and each stack registers `navigationDestination(for:)` once per route type. Don't use `NavigationLink(destination:)`: it pops right away when the presenting `@Query` list re-renders after a save.
- **Networking.** Add an endpoint as a `RequestProtocol` type under `Core/Data/api/request/`, and decode with `DataParser` into a domain struct.
- **Persistence (SwiftData).**
  - API data is cached; the only user-owned data is `PoemEntity.isFavorite`.
  - `@Model` classes (`*Entity`) are hand-written in `Core/Data/swiftData/models/`. Any change to a model needs a new `VersionedSchema` and a stage in `ChakameMigrationPlan`.
  - Writes go through `upsert(into:)` (fetch by `id`, then update or insert). Don't rely on `@Attribute(.unique)` alone: its upsert overwrites every property and would reset `isFavorite`.
  - Stores write on the **main context**, not a `@ModelActor`, because on iOS 17 `@Query` doesn't reliably refresh after background saves. Revisit when the minimum is iOS 18.
  - Views read through `@Query`, built in `init` when the filter depends on a parameter.
  - Keep a reference to the `ModelContainer` for as long as you use its `mainContext`. A context whose container was deallocated crashes.
- **Previews** use `PreviewContainer.shared` (in-memory, seeded from the mock JSON), `PreviewContainer.first/all`, and `AppDependencies.preview(container:)`.

## Rules

- No `fatalError`, `try!` or force-unwraps in new code. Throw or surface errors to the view model.
- No singletons for persistence. Inject a `ModelContext` (or a store protocol) through `init`.
- Every user-facing string goes in `Resources/Localizable.xcstrings`. See the gotchas below.
- New logic in a view model or service gets a Swift Testing unit test in `ChakameTests/Tests/<Feature>/`, using mocks and the in-memory store. There are no network calls in tests.
- Keep files small and per type, and match the existing folder for each layer.
- SwiftLint also runs as an Xcode build phase, so lint violations show up in builds.

## Agent skills

These skills are installed globally (`~/.claude/skills`, `~/.agents/skills`, Claude Code plugins). They default to the newest toolchain (Swift 6.2+, iOS 26/27). **This project uses Swift 5 language mode and iOS 17.0 for every target**, so the project's settings win when they conflict with a skill.

| Skill | Use it for | Project limits |
|---|---|---|
| `swiftui-pro` | Writing or reviewing anything under `*/Views/` | Use only APIs available on iOS 17, or wrap newer ones in `#available`. Don't raise the deployment target or the Swift version, and don't apply modernization nobody asked for. |
| `swiftdata-pro` | Writing or reviewing anything that touches `@Model`, `@Query`, `ModelContext` or the schema | Its iOS 18+ advice (`#Index`, `#Unique`) and iOS 26+ advice (model inheritance) needs an `#available` check or a higher target. Follow the main-context write rule above. |
| `swift-testing-pro` | Writing or reviewing unit tests | Write new unit tests with Swift Testing (`import Testing`, `@Suite`, `@Test`, `#expect`). Suites that use a store are `@MainActor @Suite(.serialized)` and create their own in-memory container. `RequestManagerTests` is still XCTest: leave it unless asked to migrate, and don't mix the two frameworks in one file. UI tests (`ChakameUITests`) stay XCTest, because Swift Testing doesn't support UI automation. |
| `find-skills` | Finding or installing more skills | |

Built-in commands that work well here: `/code-review` and `/simplify` before opening a PR, and `/run` to launch the app in the simulator.

## Gotchas

- **Localization.** Keys are English (`"Home"`), but the **`en` values are Persian** (`"خانه"`). The UI is Persian and RTL, so UI tests must not match on English labels.
- **Deployment targets.** All targets are iOS 17.0 (SwiftData's minimum).
- **Legacy store.** `LegacyStoreCleaner` deletes the pre-SwiftData `Chakame.sqlite` at launch. Its data, including favorites, was deliberately not migrated.
- **UI tests** run with parallel testing turned off in the shared scheme, because the test runner fails to launch on cloned simulators.
- **Settings.** The `alwaysOn` setting (`Constants.UserDefaultsKeys.alwaysOn`) toggles `UIApplication.shared.isIdleTimerDisabled`.
- **Font.** Poem text uses the bundled Vazirmatn font (`Utils/Font.swift`).
