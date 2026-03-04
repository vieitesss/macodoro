import SwiftUI
import MacodoroCore
import AppKit

struct SettingsView: View {
    @EnvironmentObject var vm: TimerViewModel
    @State private var settingsWindow: NSWindow?

    var body: some View {
        TabView {
            timerTab
                .tabItem { Label("Timer", systemImage: "timer") }
            alertsTab
                .tabItem { Label("Alerts", systemImage: "bell") }
        }
        .tint(.blue)
        .background(WindowAccessor(window: $settingsWindow))
        .onAppear(perform: bringSettingsWindowToFront)
        .onChange(of: settingsWindow) { _, _ in
            bringSettingsWindowToFront()
        }
        .onChange(of: vm.settings) { _, _ in
            vm.saveSettings()
        }
    }

    private func bringSettingsWindowToFront() {
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            settingsWindow?.makeKeyAndOrderFront(nil)
            settingsWindow?.orderFrontRegardless()
        }
    }

    private var timerTab: some View {
        Form {
            Section("Durations") {
                DurationStepper(label: "Work", duration: $vm.settings.workDuration, range: 1...120)
                DurationStepper(label: "Short rest", duration: $vm.settings.restDuration, range: 1...60)
                DurationStepper(label: "Long rest", duration: $vm.settings.bigRestDuration, range: 1...120)
            }
            Section("Cycle") {
                CountStepper(
                    label: "Rounds before long rest",
                    value: $vm.settings.iterationsBeforeBigRest,
                    range: 1...10,
                    unit: "rounds"
                )
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding(.bottom)
    }

    private var alertsTab: some View {
        Form {
            Section {
                Picker("Alert style", selection: $vm.settings.alertStyle) {
                    ForEach(AlertStyle.allCases) { style in
                        Text(style.rawValue).tag(style)
                    }
                }
                .pickerStyle(.radioGroup)
                .tint(.blue)
            }

            Section("Warnings") {
                Toggle("Notify one minute before rest ends", isOn: $vm.settings.oneMinuteRestWarningEnabled)
                    .tint(.blue)
            }
        }
        .formStyle(.grouped)
        .frame(width: 380)
        .padding(.bottom)
    }
}

// MARK: - Helpers

private struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        let binding = _window
        DispatchQueue.main.async {
            binding.wrappedValue = view.window
        }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        let binding = _window
        DispatchQueue.main.async {
            binding.wrappedValue = nsView.window
        }
    }
}

private struct CountStepper: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let unit: String

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
            Spacer()
            TextField("", text: $text)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .frame(width: 44, alignment: .trailing)
                .focused($isFocused)
                .onSubmit(commit)
            Text(unit)
            Stepper("", value: Binding(
                get: { value },
                set: { value = $0; text = "\($0)" }
            ), in: range)
                .labelsHidden()
                .fixedSize()
        }
        .frame(minHeight: 22)
        .onAppear { text = "\(value)" }
        .onChange(of: isFocused) { _, focused in
            if !focused { commit() }
        }
    }

    private func commit() {
        let parsed = Int(text.trimmingCharacters(in: .whitespaces)) ?? value
        let clamped = min(max(parsed, range.lowerBound), range.upperBound)
        value = clamped
        text = "\(clamped)"
    }
}

private struct DurationStepper: View {
    let label: String
    @Binding var duration: TimeInterval
    let range: ClosedRange<Int>

    @State private var text: String = ""
    @FocusState private var isFocused: Bool

    private var minutes: Int { Int(duration) / 60 }

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
            Spacer()
            TextField("", text: $text)
                .multilineTextAlignment(.trailing)
                .textFieldStyle(.plain)
                .frame(width: 44, alignment: .trailing)
                .focused($isFocused)
                .onSubmit(commit)
            Text("min")
            Stepper("", value: Binding(
                get: { minutes },
                set: { duration = TimeInterval($0 * 60); text = "\($0)" }
            ), in: range)
                .labelsHidden()
                .fixedSize()
        }
        .frame(minHeight: 22)
        .onAppear { text = "\(minutes)" }
        .onChange(of: isFocused) { _, focused in
            if !focused { commit() }
        }
    }

    private func commit() {
        let parsed = Int(text.trimmingCharacters(in: .whitespaces)) ?? minutes
        let clamped = min(max(parsed, range.lowerBound), range.upperBound)
        duration = TimeInterval(clamped * 60)
        text = "\(clamped)"
    }
}
