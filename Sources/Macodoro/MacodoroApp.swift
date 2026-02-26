import SwiftUI

@main
struct MacodoroApp: App {
    @StateObject private var vm = TimerViewModel()

    var body: some Scene {
        // Menu bar popover — no Dock icon (LSUIElement = true in Info.plist)
        MenuBarExtra {
            MenuBarView()
                .environmentObject(vm)
        } label: {
            Text(vm.menuBarTitle)
                .monospacedDigit()
        }
        .menuBarExtraStyle(.window)

        // Settings window — opened via Cmd+, or the "Settings…" button
        Settings {
            SettingsView()
                .environmentObject(vm)
        }
    }
}
