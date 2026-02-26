# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Macodoro** is a macOS-native Pomodoro timer application written in Swift. See `AGENTS.md` for full user requirements and implementation notes.

Key features: menu bar icon, hovering overlay mode, configurable timer, themes, transparency, alerts, local settings persistence, Homebrew distribution, and terminal scriptability.

## Build & Development Commands

```bash
make build    # swift build
make test     # swift test (with CLT framework flags baked in)
make run      # build → assemble .app bundle → open
make restart  # kill running instance, rebuild, relaunch
make clean    # wipe build artifacts and .app bundle
```

**Why the test flags?** The Command Line Tools ship `Testing.framework` in a non-standard path. `make test` already includes the necessary `-Xswiftc` / `-Xlinker` flags; you do not need Xcode.app.

Run a single test suite or test:
```bash
swift test $(FRAMEWORKS_FLAGS) --filter PomodoroTimerTests
swift test $(FRAMEWORKS_FLAGS) --filter PomodoroTimerTests/startTransitionsToWorking
```
(where `FRAMEWORKS_FLAGS` are the flags defined in the Makefile)

## Architecture

**Two SPM targets:**

- `MacodoroCore` (library) — pure Swift, no UI framework dependency; importable by tests.
  - `Settings` — `Codable` struct + `SettingsStore` (UserDefaults persistence)
  - `PomodoroTimer` — state machine; communicates changes via `onStateChange: ((PomodoroState) -> Void)?`
- `Macodoro` (executable) — SwiftUI app; imports `MacodoroCore`.
  - `TimerViewModel` — `ObservableObject` wrapping `PomodoroTimer`; the single source of truth for all views.
  - `MenuBarView` — popover content shown when clicking the menu bar icon.
  - `SettingsView` — macOS `Settings` scene (opens via Cmd+, or the in-popover button).

`LSUIElement = true` in `Info.plist` hides the app from the Dock.

The `PomodoroTimer` timer runs on `RunLoop.main` so `onStateChange` callbacks are always on the main thread — no `DispatchQueue.main` needed in `TimerViewModel`.

### Key macOS Integrations (planned)

- **Hover overlay**: `NSPanel` with `NSWindowLevel.floating` and configurable opacity
- **Alerts**: `UNUserNotificationCenter` + system sounds
- **Terminal scriptability**: Custom URL scheme (`macodoro://`) or a thin CLI wrapper
- **Homebrew**: `.cask` formula pointing to a signed `.dmg` or `.zip` release

### Implementation Notes

Refer to the `## Anything good to know for implementation` section in `AGENTS.md` — update it when discovering gotchas or non-obvious decisions during development.
