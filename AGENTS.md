# Macodoro

A MacOS-native pomodoro application.

## Purpose

Macodoro is a productivity timer application that helps users manage their work sessions using the Pomodoro Technique. It provides a clean, native Mac experience with customizable work/rest intervals, visual themes, and system integration features like menu bar presence and floating window mode.

## Maintainer Preferences

### Styling

- Follow current macOS design guidelines (SF Pro font, proper spacing, native controls)
- Use SF Symbols for icons where possible
- Support both light and dark mode natively
- Keep the UI minimal and focused on the timer
- Use subtle animations for state transitions
- Provide multiple color themes with harmonious palettes

### Behavior

- Remember window positions and sizes between sessions
- Persist all user settings locally
- Provide smooth, non-intrusive notifications
- Support keyboard shortcuts for common actions
- Gracefully handle system sleep/wake cycles
- Minimize resource usage when running in background

## Implementation Notes

- Cycle indicators in the menu bar use a two-row stage grid (top = work, bottom = rest) with one column per cycle; rows touch (`spacing: 0`) and columns are separated.
- Stage progression is tracked as a linear stage number (odd = work, even = rest) so skipping and completion advance in strict order (1 -> 2 -> 3 -> ...).
- Manual controls (`start`, `skip`, `reset`) suppress the next phase notification; phase alerts (sound/banner) are intended for automatic transitions when a stage naturally ends.
- Foreground notification banners are enabled via `UNUserNotificationCenterDelegate` (`willPresent`) so banner modes can still present while the app is active.
- When opening Settings from the menu bar, activate the app before opening the settings scene to avoid first-open window/tint inconsistencies.
