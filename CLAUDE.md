# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

GitLab Widget is a multi-platform macOS/iOS application that provides GitLab merge request management through menu bar widgets, desktop widgets, and rich notifications. The app supports both GitLab and GitHub integration with real-time CI/CD pipeline status updates.

## Build Commands

### Development Builds
```bash
# Build main macOS app (recommended)
xcodebuild -workspace GitLab.xcworkspace -scheme Merger -configuration Debug build

# Build iOS companion app
xcodebuild -workspace GitLab.xcworkspace -scheme "Merger iOS" -configuration Debug build

# Build specific widget extension
xcodebuild -workspace GitLab.xcworkspace -scheme DesktopWidgetToolExtension -configuration Debug build
```

### Testing
```bash
# Run macOS tests
xcodebuild -workspace GitLab.xcworkspace -scheme Merger -configuration Debug test

# Run iOS tests  
xcodebuild -workspace GitLab.xcworkspace -scheme "Merger iOS" -configuration Debug test
```

### Release Builds
```bash
# Archive for App Store (macOS)
xcodebuild -workspace GitLab.xcworkspace -scheme Merger -configuration Release archive

# Archive for App Store (iOS)
xcodebuild -workspace GitLab.xcworkspace -scheme "Merger iOS" -configuration Release archive
```

## Architecture Overview

### Multi-Target Structure
The project consists of 8 main targets:

1. **GitLab** - Main macOS menu bar application (`GitLab/GitLabApp.swift`)
2. **GitLab iOS** - iOS companion app (`GitLab iOS/GitLab_iOSApp.swift`)
3. **DesktopWidgetTool** - macOS desktop widgets (`DesktopWidgetTool/DesktopWidgetTool.swift`)
4. **NotificationContent** - Rich notification extension (`NotificationContent/NotificationViewController.swift`)
5. **Test targets** - Unit and UI tests for both platforms

### Shared Codebase
Core functionality is shared through `Shared/UserInterface/`:
- **Models**: `NetworkManagerGitLab.swift`, `StructsGitLab.swift`, `StructsGitHub.swift`
- **SwiftData Models**: `Account.swift`, `UniversalMergeRequest.swift`
- **UI Components**: Views, extensions, and button styles
- **Networking**: API clients using `Get` library for GitLab/GitHub APIs

### Data Persistence
- **macOS**: GRDB SQLite database with auto-migration (`~/Documents/db.sqlite`)
- **iOS**: SwiftData for local storage
- **Models**: `Account` (user credentials), `UniversalMergeRequest` (unified MR/PR model)

### Key Dependencies
- **Get** (v2.1.6) - HTTP networking for GitLab/GitHub APIs
- **GRDB.swift** (v7.4.1) - SQLite database with migrations
- **Nuke** (v12.8.0) - Image loading and caching
- **LaunchAtLogin-Modern** - Auto-launch functionality
- **Point-Free ecosystem** - Dependencies, sharing, structured queries

### Network Architecture
- `NetworkManagerGitLab` - Singleton with per-instance API clients
- Separate clients for regular API calls and launchpad queries
- Support for custom GitLab instances beyond gitlab.com
- GraphQL integration for advanced GitLab queries

### Widget System
- **LaunchPadWidget** - Quick access to repositories
- **MergeRequestWidget** - Shows authored and review-requested MRs
- Three widget sizes: Small, Medium, Large, Extra Large
- Real-time CI/CD status indicators with custom icons

## Development Setup

### Requirements
- **Xcode 15.3+** (updated to support latest iOS/macOS versions)
- **macOS Deployment Target**: Set via `$(MACOSX_DEPLOYMENT_TARGET)`
- **iOS Deployment Target**: Standard iOS deployment target

### Entitlements & Capabilities
- **App Sandbox** enabled for macOS security
- **Network Client** for GitLab/GitHub API access
- **Application Groups** for data sharing between app and extensions
- **Keychain Access** for secure token storage
- **User Selected Files** (read-only) for file access permissions

### Database Development
- SQLite database automatically created at `~/Documents/db.sqlite`
- GRDB handles schema migrations automatically
- Debug builds enable SQL tracing for development
- Use `@Table` attribute for GRDB model definitions

## Widget Development

### Widget Types
- Use `WidgetKit` framework for desktop widgets
- Entry points in `DesktopWidgetTool/` directory
- Support for timeline updates and background refresh
- Custom widget sizes with responsive layouts

### Testing Widgets
- Use WidgetKit Simulator for testing
- Widget data cached in `GitLab.widgetkitsim/widget_data/`
- Test different widget sizes and timeline scenarios

## Localization

- Project supports multiple languages via `.xcloc` files
- Localizable strings in `GitLab Localizations/Localizable.xcstrings`
- Platform-specific localization in respective target directories
- Use `LocalizedStringKey` for SwiftUI text elements