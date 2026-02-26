import SwiftUI
import MacodoroCore

struct MenuBarView: View {
    @EnvironmentObject var vm: TimerViewModel
    @Environment(\.openSettings) private var openSettings

    var body: some View {
        VStack(spacing: 20) {
            phaseHeader
            timerDisplay
            iterationDots
            controls
            Divider()
            footerButtons
        }
        .padding(24)
        .frame(width: 240)
    }

    // MARK: - Sections

    private var phaseHeader: some View {
        Text(vm.phase.label)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    private var timerDisplay: some View {
        Text(vm.displayTime)
            .font(.system(size: 52, weight: .thin, design: .monospaced))
            .monospacedDigit()
    }

    private var iterationDots: some View {
        HStack(spacing: 8) {
            ForEach(0..<vm.settings.iterationsBeforeBigRest, id: \.self) { i in
                Circle()
                    .fill(i < vm.completedIterations ? Color.accentColor : Color.secondary.opacity(0.25))
                    .frame(width: 8, height: 8)
            }
        }
    }

    private var controls: some View {
        HStack(spacing: 20) {
            Button(action: vm.reset) {
                Image(systemName: "arrow.counterclockwise")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .help("Reset")

            Button(action: vm.isRunning ? vm.pause : vm.start) {
                Image(systemName: vm.isRunning ? "pause.fill" : "play.fill")
                    .font(.title)
            }
            .buttonStyle(.plain)
            .help(vm.isRunning ? "Pause" : "Start")

            Button(action: vm.skip) {
                Image(systemName: "forward.end.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
            .help("Skip to next phase")
        }
    }

    private var footerButtons: some View {
        VStack(spacing: 4) {
            Button("Settings…") { openSettings() }
                .buttonStyle(.plain)
            Button("Quit") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
        }
    }
}
