import Foundation

public enum AlertStyle: String, Codable, CaseIterable, Identifiable {
    case none           = "None"
    case soundOnly      = "Sound"
    case bannerOnly     = "Banner"
    case soundAndBanner = "Sound & Banner"
    public var id: String { rawValue }
}

public struct Settings: Codable, Equatable {
    public var workDuration: TimeInterval       // seconds
    public var restDuration: TimeInterval       // seconds
    public var bigRestDuration: TimeInterval    // seconds
    public var iterationsBeforeBigRest: Int
    public var alertStyle: AlertStyle
    public var oneMinuteRestWarningEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case workDuration
        case restDuration
        case bigRestDuration
        case iterationsBeforeBigRest
        case alertStyle
        case oneMinuteRestWarningEnabled
    }

    public init(
        workDuration: TimeInterval = 25 * 60,
        restDuration: TimeInterval = 5 * 60,
        bigRestDuration: TimeInterval = 15 * 60,
        iterationsBeforeBigRest: Int = 4,
        alertStyle: AlertStyle = .soundAndBanner,
        oneMinuteRestWarningEnabled: Bool = true
    ) {
        self.workDuration = workDuration
        self.restDuration = restDuration
        self.bigRestDuration = bigRestDuration
        self.iterationsBeforeBigRest = iterationsBeforeBigRest
        self.alertStyle = alertStyle
        self.oneMinuteRestWarningEnabled = oneMinuteRestWarningEnabled
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        workDuration = try container.decode(TimeInterval.self, forKey: .workDuration)
        restDuration = try container.decode(TimeInterval.self, forKey: .restDuration)
        bigRestDuration = try container.decode(TimeInterval.self, forKey: .bigRestDuration)
        iterationsBeforeBigRest = try container.decode(Int.self, forKey: .iterationsBeforeBigRest)
        alertStyle = try container.decodeIfPresent(AlertStyle.self, forKey: .alertStyle) ?? .soundAndBanner
        oneMinuteRestWarningEnabled = try container.decodeIfPresent(Bool.self, forKey: .oneMinuteRestWarningEnabled) ?? true
    }

    public static let `default` = Settings()
}

public final class SettingsStore {
    private let key = "macodoro.settings"

    public init() {}

    public var settings: Settings {
        get {
            guard
                let data = UserDefaults.standard.data(forKey: key),
                let decoded = try? JSONDecoder().decode(Settings.self, from: data)
            else { return .default }
            return decoded
        }
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
