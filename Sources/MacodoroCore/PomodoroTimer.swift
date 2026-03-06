import Foundation

public enum TimerPhase: Equatable {
    case idle
    case working
    case resting
    case bigResting

    public var label: String {
        switch self {
        case .idle:       return "Ready"
        case .working:    return "Work"
        case .resting:    return "Short Rest"
        case .bigResting: return "Long Rest"
        }
    }
}

public struct PomodoroState: Equatable {
    public var phase: TimerPhase
    public var timeRemaining: TimeInterval
    public var completedIterations: Int

    public init(phase: TimerPhase, timeRemaining: TimeInterval, completedIterations: Int) {
        self.phase = phase
        self.timeRemaining = timeRemaining
        self.completedIterations = completedIterations
    }

    public static let initial = PomodoroState(phase: .idle, timeRemaining: 0, completedIterations: 0)
}

public final class PomodoroTimer {
    public private(set) var state: PomodoroState = .initial
    public var onStateChange: ((PomodoroState) -> Void)?

    private var settings: Settings
    private var timer: Timer?

    public init(settings: Settings) {
        self.settings = settings
    }

    // MARK: - Public controls

    public func start() {
        guard timer == nil else { return }
        if state.phase == .idle {
            state = PomodoroState(
                phase: .working,
                timeRemaining: settings.workDuration,
                completedIterations: 0
            )
        }
        scheduleTimer()
        notify()
    }

    public func pause() {
        timer?.invalidate()
        timer = nil
    }

    public func reset() {
        timer?.invalidate()
        timer = nil
        state = .initial
        notify()
    }

    /// Restarts the timer for the current phase only.
    /// Keeps the same phase and iteration count, but resets time to full duration.
    public func restartTimer() {
        let wasRunning = timer != nil
        timer?.invalidate()
        timer = nil

        let duration: TimeInterval
        switch state.phase {
        case .idle:
            duration = settings.workDuration
        case .working:
            duration = settings.workDuration
        case .resting:
            duration = settings.restDuration
        case .bigResting:
            duration = settings.bigRestDuration
        }

        state = PomodoroState(
            phase: state.phase,
            timeRemaining: duration,
            completedIterations: state.completedIterations
        )

        if wasRunning {
            scheduleTimer()
        }
        notify()
    }

    /// Advances to the next phase.
    /// Keeps running only if the timer was already active.
    public func skip() {
        let wasRunning = timer != nil
        advance(autostart: wasRunning)
    }

    public func update(settings: Settings) {
        self.settings = settings
    }

    // MARK: - Private

    private func scheduleTimer() {
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        if state.timeRemaining > 0 {
            state.timeRemaining -= 1
            notify()
        } else {
            advance(autostart: true)
        }
    }

    private func advance(autostart: Bool) {
        timer?.invalidate()
        timer = nil

        switch state.phase {
        case .idle:
            let newIterations = 1
            if newIterations >= settings.iterationsBeforeBigRest {
                state = PomodoroState(
                    phase: .bigResting,
                    timeRemaining: settings.bigRestDuration,
                    completedIterations: 0
                )
            } else {
                state = PomodoroState(
                    phase: .resting,
                    timeRemaining: settings.restDuration,
                    completedIterations: newIterations
                )
            }
        case .working:
            let newIterations = state.completedIterations + 1
            if newIterations >= settings.iterationsBeforeBigRest {
                state = PomodoroState(
                    phase: .bigResting,
                    timeRemaining: settings.bigRestDuration,
                    completedIterations: 0
                )
            } else {
                state = PomodoroState(
                    phase: .resting,
                    timeRemaining: settings.restDuration,
                    completedIterations: newIterations
                )
            }
        case .resting, .bigResting:
            state = PomodoroState(
                phase: .working,
                timeRemaining: settings.workDuration,
                completedIterations: state.completedIterations
            )
        }

        if autostart {
            scheduleTimer()
        }
        notify()
    }

    private func notify() {
        onStateChange?(state)
    }
}
