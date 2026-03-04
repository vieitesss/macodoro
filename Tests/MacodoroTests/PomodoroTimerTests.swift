import Testing
@testable import MacodoroCore

@Suite("PomodoroTimer")
struct PomodoroTimerTests {
    let settings = Settings(
        workDuration: 3,
        restDuration: 2,
        bigRestDuration: 10,
        iterationsBeforeBigRest: 2
    )

    func makeTimer() -> PomodoroTimer { PomodoroTimer(settings: settings) }

    @Test func initialStateIsIdle() {
        let timer = makeTimer()
        #expect(timer.state == .initial)
        #expect(timer.state.phase == .idle)
    }

    @Test func startTransitionsToWorking() {
        let timer = makeTimer()
        timer.start()
        defer { timer.reset() }
        #expect(timer.state.phase == .working)
        #expect(timer.state.timeRemaining == settings.workDuration)
        #expect(timer.state.completedIterations == 0)
    }

    @Test func skipFromWorkingGoesToResting() {
        let timer = makeTimer()
        timer.start()
        defer { timer.reset() }
        timer.skip()
        #expect(timer.state.phase == .resting)
        #expect(timer.state.timeRemaining == settings.restDuration)
        #expect(timer.state.completedIterations == 1)
    }

    @Test func skipFromRestingGoesToWorking() {
        let timer = makeTimer()
        timer.start()
        defer { timer.reset() }
        timer.skip() // working → resting
        timer.skip() // resting  → working
        #expect(timer.state.phase == .working)
        #expect(timer.state.completedIterations == 1)
    }

    @Test func completingAllIterationsGoesToBigRest() {
        let timer = makeTimer()
        timer.start()
        defer { timer.reset() }
        timer.skip() // working(0) → resting(1)
        timer.skip() // resting(1) → working(1)
        timer.skip() // working(1) → bigResting — limit reached
        #expect(timer.state.phase == .bigResting)
        #expect(timer.state.timeRemaining == settings.bigRestDuration)
        #expect(timer.state.completedIterations == 0)
    }

    @Test func resetReturnsToInitial() {
        let timer = makeTimer()
        timer.start()
        timer.skip()
        timer.reset()
        #expect(timer.state == .initial)
    }

    @Test func skipWhenIdleGoesToResting() {
        let timer = makeTimer()
        timer.skip()
        #expect(timer.state.phase == .resting)
        #expect(timer.state.timeRemaining == settings.restDuration)
        #expect(timer.state.completedIterations == 1)
    }

    @Test func updatedSettingsTakeEffectOnNextPhase() {
        let timer = makeTimer()
        timer.start()
        defer { timer.reset() }
        let newSettings = Settings(workDuration: 60, restDuration: 30, bigRestDuration: 10, iterationsBeforeBigRest: 2)
        timer.update(settings: newSettings)
        timer.skip() // working → resting with new restDuration
        #expect(timer.state.timeRemaining == newSettings.restDuration)
    }
}
