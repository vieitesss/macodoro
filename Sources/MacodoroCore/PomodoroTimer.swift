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

    /// Advances to the next phase; keeps running if the timer was active.
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
            return
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
