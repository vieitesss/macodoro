import SwiftUI
import MacodoroCore

struct MenuBarView: View {
    @EnvironmentObject var vm: TimerViewModel
    @Environment(\.openSettings) private var openSettings
    @State private var hoveredFooterOption: FooterOption?

    private enum FooterOption {
        case settings
        case about
        case quit
    }

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
            ForEach(0..<vm.settings.iterationsBeforeBigRest, id: \.self) { cycleIndex in
                VStack(spacing: 0) {
                    cycleBox(stageNumber: workStageNumber(for: cycleIndex))
                    cycleBox(stageNumber: restStageNumber(for: cycleIndex))
                }
            }
        }
    }

    private func workStageNumber(for cycleIndex: Int) -> Int {
        cycleIndex * 2 + 1
    }

    private func restStageNumber(for cycleIndex: Int) -> Int {
        cycleIndex * 2 + 2
    }

    private func cycleBox(stageNumber: Int) -> some View {
        let isInProgress = stageNumber == vm.activeStageNumber
        let isCompleted = stageNumber < vm.activeStageNumber

        return RoundedRectangle(cornerRadius: 2, style: .continuous)
            .fill(boxColor(isCompleted: isCompleted, isInProgress: isInProgress))
            .frame(width: 16, height: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .stroke(boxBorderColor(isInProgress: isInProgress), lineWidth: isInProgress ? 1.5 : 0)
            )
    }

    private func boxColor(isCompleted: Bool, isInProgress: Bool) -> Color {
        if isInProgress {
            return Color.accentColor.opacity(0.3)
        } else if isCompleted {
            return Color.accentColor
        } else {
            return Color.secondary.opacity(0.25)
        }
    }

    private func boxBorderColor(isInProgress: Bool) -> Color {
        isInProgress ? Color.accentColor : .clear
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
        VStack(spacing: 1) {
            footerButton("Settings…", option: .settings) {
                NSApplication.shared.activate(ignoringOtherApps: true)
                openSettings()
            }
            footerButton("About Macodoro", option: .about) {
                NSApplication.shared.activate(ignoringOtherApps: true)
                NSApplication.shared.orderFrontStandardAboutPanel(nil)
            }
            footerButton("Quit", option: .quit) {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(3)
        .background(
            RoundedRectangle(cornerRadius: 9, style: .continuous)
                .fill(Color.primary.opacity(0.07))
        )
    }

    private func footerButton(_ title: String, option: FooterOption, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 9)
                .padding(.vertical, 3)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(hoveredFooterOption == option ? Color.white : Color.primary)
        .background(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(hoveredFooterOption == option ? Color.accentColor : .clear)
        )
        .onHover { isHovering in
            if isHovering {
                hoveredFooterOption = option
            } else if hoveredFooterOption == option {
                hoveredFooterOption = nil
            }
        }
    }
}
