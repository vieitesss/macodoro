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
        HStack(spacing: 10) {
            controlButton(
                title: "Cycle",
                systemImage: "arrow.counterclockwise",
                imageFont: .title3,
                helpText: "Restart entire cycle",
                action: vm.reset
            )

            controlButton(
                title: "Timer",
                systemImage: "arrow.clockwise",
                imageFont: .title3,
                helpText: "Restart current timer",
                action: vm.restartTimer
            )

            controlButton(
                title: vm.isRunning ? "Pause" : "Start",
                systemImage: vm.isRunning ? "pause.fill" : "play.fill",
                imageFont: .title,
                helpText: vm.isRunning ? "Pause timer" : "Start timer",
                action: vm.isRunning ? vm.pause : vm.start
            )

            controlButton(
                title: "Skip",
                systemImage: "forward.end.fill",
                imageFont: .title3,
                helpText: "Skip to next phase",
                action: vm.skip
            )
        }
    }

    private func controlButton(
        title: String,
        systemImage: String,
        imageFont: Font,
        helpText: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(imageFont)
                    .frame(height: 20)

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .help(helpText)
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
