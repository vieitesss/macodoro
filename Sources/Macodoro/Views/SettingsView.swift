import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var vm: TimerViewModel

    var body: some View {
        Form {
            Section("Timer") {
                DurationStepper(label: "Work", duration: $vm.settings.workDuration, range: 1...120)
                DurationStepper(label: "Short rest", duration: $vm.settings.restDuration, range: 1...60)
                DurationStepper(label: "Long rest", duration: $vm.settings.bigRestDuration, range: 1...120)
            }
            Section("Cycle") {
                Stepper(
                    "Rounds before long rest: \(vm.settings.iterationsBeforeBigRest)",
                    value: $vm.settings.iterationsBeforeBigRest,
                    in: 1...10
                )
            }
        }
        .formStyle(.grouped)
        .frame(width: 380, height: 280)
        .onChange(of: vm.settings) { _, _ in
            vm.saveSettings()
        }
    }
}

// MARK: - Helpers

private struct DurationStepper: View {
    let label: String
    @Binding var duration: TimeInterval
    let range: ClosedRange<Int>

    private var minutes: Binding<Int> {
        Binding(
            get: { Int(duration) / 60 },
            set: { duration = TimeInterval($0 * 60) }
        )
    }

    var body: some View {
        Stepper(
            "\(label): \(Int(duration) / 60) min",
            value: minutes,
            in: range
        )
    }
}
