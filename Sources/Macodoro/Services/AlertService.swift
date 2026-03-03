import AppKit
import UserNotifications
import MacodoroCore

final class AlertService {
    static let shared = AlertService()

    func requestPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { _, _ in }
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
}
