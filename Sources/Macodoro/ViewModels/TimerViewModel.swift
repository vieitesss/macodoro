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

    // MARK: - Controls

    func start() {
        timer.start()
        isRunning = true
    }

    func pause() {
        timer.pause()
        isRunning = false
    }

    func reset() {
        timer.reset()
        isRunning = false
    }

    func skip() {
        timer.skip()
    }

    /// Persists settings and pushes them into the running timer.
    func saveSettings() {
        store.settings = settings
        timer.update(settings: settings)
    }

    // MARK: - Private

    private func apply(_ state: PomodoroState) {
        let previous = phase
        phase = state.phase
        timeRemaining = state.timeRemaining
        completedIterations = state.completedIterations

        if state.phase != previous {
            AlertService.shared.notify(for: state.phase, style: settings.alertStyle)
        }
    }

    private func formatted(_ interval: TimeInterval) -> String {
        let m = Int(interval) / 60
        let s = Int(interval) % 60
        return String(format: "%02d:%02d", m, s)
    }
}
