# Open Music Event

A dual-platform mobile application for music festival management, built with Swift and targeting both iOS and Android through the Skip framework.

## Overview

Open Music Event is a comprehensive festival companion app that helps attendees navigate music events with features for artist discovery, schedule management, and venue information. The app is built using a single Swift codebase that compiles natively for iOS and compiles to Kotlin for Android.

## Features

- **Artist Discovery**: Browse festival lineups with detailed artist information
- **Schedule Management**: Interactive timeline views with personalized scheduling
- **Venue Navigation**: Stage locations and venue maps
- **Offline Support**: Local SQLite database for offline access
- **Cross-Platform**: Native performance on both iOS and Android

## Architecture

The project uses a modular architecture with three main packages:

```
open-music-event/
├── Sources/OpenMusicEvent/        # Main SwiftUI application
├── Core/                          # Shared business logic
│   ├── CoreModels/                   # Database models (GRDB)
│   ├── OpenMusicEventParser/         # YAML/Markdown parsing
│   └── OpenMusicEventCLI/            # Command-line interface
├── Darwin/                        # iOS-specific configuration
└── Android/                       # Android-specific configuration
```

## Getting Started

### Prerequisites
- Swift 6.1+
- Xcode 15+ (for iOS development)
- Skip framework (for Android transpilation)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/open-music-event.git
   cd open-music-event
   ```

2. **Install dependencies**
   ```bash
   swift package resolve
   ```

3. **Build the project**
   ```bash
   swift build
   ```

### Running the App

#### iOS
```bash
# Open in Xcode
open /Darwin/OpenMusicEvent.xcworkspace

# Or build from command line
swift build
```

#### Android
```bash
# Ensure Skip is installed
skip checkup

# Build for Android
skip build
```

#### CLI Tool
```bash
# Build the CLI
swift build --product open-music-event

# Run validation
.build/debug/open-music-event validate path/to/festival/data
```

### Testing

```bash
# Run Swift tests
swift test

# Run cross-platform tests (Swift + Kotlin)
skip test

# Run specific test plans
swift test --testplan Core/Tests/OpenMusicEventParser.xctestplan
```

## Data Format

The app consumes festival data in a structured format:

- **Event Configuration**: YAML files with event metadata
- **Artist Information**: Markdown files with artist details  
- **Schedules**: YAML files defining performance times and stages
- **Assets**: Images and other media files

Example event structure:
```
festival-name/
├── event-info.yml
├── artists/
│   ├── artist-name.md
│   └── ...
└── schedules/
    ├── 2024-07-01.yml
    └── ...
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`swift test && skip test`)
6. Commit your changes (`git commit -m 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

## License

[Add your license information here]

## Support

For questions, issues, or contributions, please:
- Open an issue on GitHub
- Check the [CLAUDE.md](./CLAUDE.md) for detailed development guidance
- Review existing documentation and code examples
