# Chakame

Chakame is an iOS app that provides access to a collection of Persian poems using the Ganjoor API. It allows users to enjoy reading numerous Persian poems conveniently, with locally stored data.

## Features

- **Ganjoor API Integration**: Accesses the Ganjoor API to retrieve a collection of Iranian poems.
- **SwiftData**: Utilizes SwiftData for local data storage, allowing poems to be stored and accessed offline.
- **SwiftUI**: Built using SwiftUI for a modern and intuitive user interface.
- **Open Source**: The project is open source, welcoming contributions from the community.

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/miladajilian/chakame.git
   ```
2. Open Chakame.xcodeproj in Xcode.
3. Build and run the project on your iOS device or simulator.

## Development

Requires Xcode 16 or later. The project uses synchronized folders, so files added on disk are picked up automatically. The lint and format tools are optional locally, but CI runs lint.

```bash
brew install swiftlint swiftformat xcbeautify
make help     # list commands
make build
make test     # unit tests
make lint
```

Conventions for contributors and AI coding agents are in [CLAUDE.md](CLAUDE.md) (also available as `AGENTS.md`).

## How to Use

Upon launching the app, poems are fetched from the Ganjoor API.
Browse and read Persian poems conveniently.
Poems are stored locally after the initial download, allowing offline access.

## Contributing

Contributions are welcome! :) 

## License

This project is open source and available under the MIT License.


Built with ❤️ by Milad.
