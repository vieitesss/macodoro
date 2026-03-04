import AppKit
import UserNotifications
import MacodoroCore

final class AlertService: NSObject, UNUserNotificationCenterDelegate {
    static let shared = AlertService()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestPermission() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notify(for phase: TimerPhase, style: AlertStyle) {
        guard style != .none else { return }
        if style == .soundOnly || style == .soundAndBanner {
            NSSound(named: .init("Glass"))?.play()
        }
        if style == .bannerOnly || style == .soundAndBanner {
            let content = UNMutableNotificationContent()
            content.title = phase.notificationTitle
            content.body  = phase.notificationBody
            let req = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: nil)
            UNUserNotificationCenter.current().add(req)
        }
    }

    func notifyOneMinuteRestRemaining(for phase: TimerPhase, style: AlertStyle) {
        guard style != .none else { return }
        if style == .soundOnly || style == .soundAndBanner {
            NSSound(named: .init("Ping"))?.play()
        }
        if style == .bannerOnly || style == .soundAndBanner {
            let content = UNMutableNotificationContent()
            content.title = phase.oneMinuteWarningTitle
            content.body = phase.oneMinuteWarningBody
            let req = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content, trigger: nil)
            UNUserNotificationCenter.current().add(req)
        }
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list])
    }
}

private extension TimerPhase {
    var notificationTitle: String {
        switch self {
        case .idle:       return "Timer stopped"
        case .working:    return "Back to work!"
        case .resting:    return "Take a short break"
        case .bigResting: return "Time for a long break"
        }
    }
    var notificationBody: String {
        switch self {
        case .idle:       return ""
        case .working:    return "A new pomodoro starts now."
        case .resting:    return "You've earned a 5-minute rest."
        case .bigResting: return "Great session — enjoy your long break."
        }
    }

    var oneMinuteWarningTitle: String {
        switch self {
        case .resting:    return "Break ending soon"
        case .bigResting: return "Long break ending soon"
        case .idle, .working:
            return "Timer update"
        }
    }

    var oneMinuteWarningBody: String {
        switch self {
        case .resting, .bigResting:
            return "One minute left before work resumes."
        case .idle, .working:
            return ""
        }
    }
}
