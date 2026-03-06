import Combine
import Foundation
import MacodoroCore

final class TimerViewModel: ObservableObject {
    @Published var phase: TimerPhase = .idle
    @Published var timeRemaining: TimeInterval = 0
    @Published var completedIterations: Int = 0
    @Published var isRunning: Bool = false
    @Published var settings: Settings

    private let store = SettingsStore()
    private let timer: PomodoroTimer
    private var suppressNextPhaseAlert = false

    init() {
        let saved = store.settings
        self.settings = saved
        self.timer = PomodoroTimer(settings: saved)

        timer.onStateChange = { [weak self] state in
            // Timer callbacks run on the main RunLoop, so this is main-thread safe.
            self?.apply(state)
        }

        AlertService.shared.requestPermission()
    }

    // MARK: - Formatted output

    /// Time shown in the popover (shows configured work duration when idle).
    var displayTime: String {
        phase == .idle ? formatted(settings.workDuration) : formatted(timeRemaining)
    }

    var activeStageNumber: Int {
        let cycleCount = max(settings.iterationsBeforeBigRest, 1)
        let maxStageNumber = cycleCount * 2

        let rawStageNumber: Int
        switch phase {
        case .idle:
            rawStageNumber = 1
        case .working:
            rawStageNumber = completedIterations * 2 + 1
        case .resting:
            rawStageNumber = max(completedIterations, 1) * 2
        case .bigResting:
            rawStageNumber = maxStageNumber
        }

        return min(max(rawStageNumber, 1), maxStageNumber)
    }

    // MARK: - Controls

    func start() {
        if phase == .idle {
            suppressNextPhaseAlert = true
        }
        timer.start()
        isRunning = true
    }

    func pause() {
        timer.pause()
        isRunning = false
    }

    func reset() {
        if phase != .idle {
            suppressNextPhaseAlert = true
        }
        timer.reset()
        isRunning = false
    }

    func restartTimer() {
        suppressNextPhaseAlert = true
        timer.restartTimer()
    }

    func skip() {
        suppressNextPhaseAlert = true
        timer.skip()
    }

    /// Persists settings and pushes them into the running timer.
    func saveSettings() {
        store.settings = settings
        timer.update(settings: settings)
    }

    // MARK: - Private

    private func apply(_ state: PomodoroState) {
        let previousPhase = phase
        let previousTimeRemaining = timeRemaining

        phase = state.phase
        timeRemaining = state.timeRemaining
        completedIterations = state.completedIterations

        if state.phase != previousPhase {
            if suppressNextPhaseAlert {
                suppressNextPhaseAlert = false
                return
            }
            AlertService.shared.notify(for: state.phase, style: settings.alertStyle)
            return
        }

        let isRestPhase = state.phase == .resting || state.phase == .bigResting
        let reachedOneMinuteLeft = previousTimeRemaining > 60 && state.timeRemaining <= 60

        if settings.oneMinuteRestWarningEnabled && isRestPhase && reachedOneMinuteLeft {
            AlertService.shared.notifyOneMinuteRestRemaining(for: state.phase, style: settings.alertStyle)
        }
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
