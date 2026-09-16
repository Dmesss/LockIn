import AppKit
import Foundation
import CoreGraphics

public enum DuckHat: String, CaseIterable {
    case none = "none"
    case sunglasses = "sunglasses"
    case cowboy = "cowboy"
    case crown = "crown"
    case ninja = "ninja"
    case wizard = "wizard"
    case detective = "detective"
    case straw = "straw"
    case hardHat = "hardhat"
    case sprout = "sprout"

    public var displayName: String {
        switch self {
        case .none: return "None"
        case .sunglasses: return "Sunglasses"
        case .cowboy: return "Cowboy Hat"
        case .crown: return "Crown"
        case .ninja: return "Ninja Headband"
        case .wizard: return "Wizard Hat"
        case .detective: return "Detective Cap"
        case .straw: return "Straw Hat"
        case .hardHat: return "Hard Hat"
        case .sprout: return "Plant Sprout"
        }
    }
}

public enum DuckAction: String, CaseIterable {
    case idle
    case waddleLeft = "waddle_left"
    case waddleRight = "waddle_right"
    case peck
    case preen
    case stretch
    case sleep
    case vibeMusic = "vibe_music"
    case swimming
    case swimLeft = "swim_left"
    case swimRight = "swim_right"
    case typing
    case jump
    case fall
    case dragged
    case quack
    case pomodoro
    case drinking
    case climbing
}

public class DuckState {
    public static let shared = DuckState()

    public var currentAction: DuckAction = .idle
    public var facingLeft: Bool = false
    public var isPlayingMusic: Bool = false
    public var currentTrack: String = ""
    public var currentArtist: String = ""
    public var currentArtworkUrl: String = ""
    public var currentArtwork: NSImage? = nil
    public var currentPosition: Double = 0.0
    public var currentDuration: Double = 0.0

    // Eye Cursor Tracking
    public var eyeOffsetX: CGFloat = 0.0
    public var eyeOffsetY: CGFloat = 0.0

    // Keyboard Typing State
    public var isTyping: Bool = false
    public var isOverheating: Bool = false

    // Pomodoro & Focus Task State
    public var isPomodoroActive: Bool = false
    public var focusTask: String = ""

    // Wardrobe System
    public var currentHat: DuckHat = .none {
        didSet { UserDefaults.standard.set(currentHat.rawValue, forKey: "DuckPet_CurrentHat") }
    }

    // Real-Time Weather State
    public var weatherTemp: Double = 28.0
    public var weatherFeelsLike: Double = 30.0
    public var weatherHumidity: Int = 65
    public var weatherCity: String = "Tangerang"
    public var weatherCondition: String = "Partly Cloudy"
    public var weatherIcon: String = "cloud.sun.fill"
    public var isRaining: Bool = false {
        didSet { isRainMode = isRaining }
    }
    public var isNight: Bool = false {
        didSet { isNightMode = isNight }
    }
    public var isHotSunny: Bool = false

    // Atmosphere (Day / Night / Rain)
    public var isAutoDayNight: Bool = true {
        didSet { UserDefaults.standard.set(isAutoDayNight, forKey: "DuckPet_AutoDayNight") }
    }
    public var isNightMode: Bool = false {
        didSet { UserDefaults.standard.set(isNightMode, forKey: "DuckPet_NightMode") }
    }
    public var isRainMode: Bool = false {
        didSet { UserDefaults.standard.set(isRainMode, forKey: "DuckPet_RainMode") }
    }

    public var isNightTime: Bool {
        if !isAutoDayNight { return isNightMode }
        let hour = Calendar.current.component(.hour, from: Date())
        return hour >= 18 || hour < 6
    }

    // System Stats & Mac Companion
    public var hasBattery: Bool = true
    public var batteryPercent: Int = 100
    public var isCharging: Bool = false
    public var isLowBattery: Bool = false
    public var cpuUsage: Double = 0.0
    public var isHighCpu: Bool = false

    public var enableSystemReactions: Bool = true {
        didSet { UserDefaults.standard.set(enableSystemReactions, forKey: "DuckPet_EnableSystemReactions") }
    }

    // Energy & Pond system
    public var energy: Double = 100.0
    public var isPondLocked: Bool = false
    public var pondRect: CGRect = .zero

    public var isTired: Bool {
        return energy <= 25.0
    }

    // Settings
    public var perchOnWindows: Bool = true
    public var stayWherePut: Bool = false
    public var showSpotifyBubble: Bool = true



    // MARK: - Tamagotchi & Mood System
    public var happiness: Double = 90.0 {
        didSet { UserDefaults.standard.set(happiness, forKey: "DuckPet_Happiness") }
    }
    public var hunger: Double = 85.0 {
        didSet { UserDefaults.standard.set(hunger, forKey: "DuckPet_Hunger") }
    }
    public var userName: String = "Dmess" {
        didSet { UserDefaults.standard.set(userName, forKey: "DuckPet_UserName") }
    }
    public var userHandle: String = "@dev" {
        didSet { UserDefaults.standard.set(userHandle, forKey: "DuckPet_UserHandle") }
    }
    public var userAvatar: String = "/sprites/user_avatar_dmess.png" {
        didSet { UserDefaults.standard.set(userAvatar, forKey: "DuckPet_UserAvatar") }
    }
    public var userTier: String = "Pro Member" {
        didSet { UserDefaults.standard.set(userTier, forKey: "DuckPet_UserTier") }
    }

    public var pomodoroSoundFX: String = "lofi" {
        didSet { UserDefaults.standard.set(pomodoroSoundFX, forKey: "DuckPet_SoundFX") }
    }

    public var moodTitle: String {
        if isPomodoroActive { return "Deep Focus Mode" }
        if isPlayingMusic { return "Grooving to Music" }
        if isRaining { return "Chilling in the Rain" }
        if isHotSunny { return "Sunny Day Outside" }
        if energy <= 25.0 { return "Sleepy & Tired" }
        if hunger <= 30.0 { return "Hungry for Snacks" }
        if energy >= 80.0 && happiness >= 80.0 { return "Energetic & Happy" }
        return "Relaxed & Happy"
    }

    public var moodDesc: String {
        if isPomodoroActive { return "Duck is wearing glasses and studying with you!" }
        if isPlayingMusic { return "Nodding along to the rhythm of the music." }
        if isRaining { return "Enjoying the cool rain showers outside 🌧️" }
        if isHotSunny { return "It is pretty sunny outside, stay hydrated! ☀️" }
        if energy <= 25.0 { return "Low energy, send duck to the pond to sleep." }
        if hunger <= 30.0 { return "Duck tummy is empty, feed some bread!" }
        if energy >= 80.0 && happiness >= 80.0 { return "Full of energy and ready for a deep work session." }
        return "Chilling on your desktop while you work."
    }

    // MARK: - Gamification & Economy System
    public var focusCoins: Int = 350 {
        didSet { UserDefaults.standard.set(focusCoins, forKey: "DuckPet_FocusCoins") }
    }
    public var totalFocusMinutes: Int = 45 {
        didSet { UserDefaults.standard.set(totalFocusMinutes, forKey: "DuckPet_TotalFocusMinutes") }
    }
    public var completedSessionsCount: Int = 3 {
        didSet { UserDefaults.standard.set(completedSessionsCount, forKey: "DuckPet_CompletedSessions") }
    }
    public var unlockedHats: Set<String> = Set(DuckHat.allCases.map { $0.rawValue }) {
        didSet {
            UserDefaults.standard.set(Array(unlockedHats), forKey: "DuckPet_UnlockedHats")
        }
    }

    public func hatPrice(_ hatId: String) -> Int {
        switch hatId {
        case "none": return 0
        case "sunglasses": return 150
        case "straw": return 250
        case "hardhat": return 400
        case "cowboy": return 600
        case "sprout": return 750
        case "detective": return 900
        case "ninja": return 1200
        case "wizard": return 1500
        case "crown": return 2500
        default: return 500
        }
    }

    public func hatRarity(_ hatId: String) -> String {
        switch hatId {
        case "none": return "Common"
        case "sunglasses", "straw": return "Common"
        case "hardhat", "cowboy", "sprout": return "Rare"
        case "detective", "ninja", "wizard": return "Epic"
        case "crown": return "Legendary"
        default: return "Common"
        }
    }

    public func addFocusCoins(_ amount: Int) {
        focusCoins = max(0, focusCoins + amount)
    }

    public func buyHat(_ hatId: String) -> (success: Bool, error: String?) {
        guard let hatEnum = DuckHat(rawValue: hatId) else {
            return (false, "Invalid accessory")
        }
        currentHat = hatEnum
        return (true, nil)
    }

    private init() {
        let saved = UserDefaults.standard.string(forKey: "DuckPet_FocusTask") ?? ""
        if saved == "UI Design" {
            UserDefaults.standard.removeObject(forKey: "DuckPet_FocusTask")
            focusTask = ""
        } else {
            focusTask = saved
        }
        if UserDefaults.standard.object(forKey: "DuckPet_Happiness") != nil {
            happiness = UserDefaults.standard.double(forKey: "DuckPet_Happiness")
        }
        if UserDefaults.standard.object(forKey: "DuckPet_Hunger") != nil {
            hunger = UserDefaults.standard.double(forKey: "DuckPet_Hunger")
        }
        if let savedName = UserDefaults.standard.string(forKey: "DuckPet_UserName") {
            userName = (savedName == "Angel") ? "Dmess" : savedName
        }
        if let savedHandle = UserDefaults.standard.string(forKey: "DuckPet_UserHandle") {
            userHandle = (savedHandle == "@yea") ? "@dev" : savedHandle
        }
        if let savedAvatar = UserDefaults.standard.string(forKey: "DuckPet_UserAvatar") {
            userAvatar = (savedAvatar.contains("user_avatar_angel")) ? "/sprites/user_avatar_dmess.png" : savedAvatar
        }
        if let savedTier = UserDefaults.standard.string(forKey: "DuckPet_UserTier") {
            userTier = savedTier
        }
        if let savedSound = UserDefaults.standard.string(forKey: "DuckPet_SoundFX") {
            pomodoroSoundFX = savedSound
        }

        if UserDefaults.standard.object(forKey: "DuckPet_FocusCoins") != nil {
            focusCoins = UserDefaults.standard.integer(forKey: "DuckPet_FocusCoins")
        }
        if UserDefaults.standard.object(forKey: "DuckPet_TotalFocusMinutes") != nil {
            totalFocusMinutes = UserDefaults.standard.integer(forKey: "DuckPet_TotalFocusMinutes")
        }
        if UserDefaults.standard.object(forKey: "DuckPet_CompletedSessions") != nil {
            completedSessionsCount = UserDefaults.standard.integer(forKey: "DuckPet_CompletedSessions")
        }
        // All wardrobe hats unlocked by default on macOS
        unlockedHats = Set(DuckHat.allCases.map { $0.rawValue })

        if let savedHat = UserDefaults.standard.string(forKey: "DuckPet_CurrentHat"),
           let hat = DuckHat(rawValue: savedHat) {
            currentHat = hat
        }
        if UserDefaults.standard.object(forKey: "DuckPet_AutoDayNight") != nil {
            isAutoDayNight = UserDefaults.standard.bool(forKey: "DuckPet_AutoDayNight")
        }
        isNightMode = UserDefaults.standard.bool(forKey: "DuckPet_NightMode")
        isRainMode = UserDefaults.standard.bool(forKey: "DuckPet_RainMode")
        if UserDefaults.standard.object(forKey: "DuckPet_EnableSystemReactions") != nil {
            enableSystemReactions = UserDefaults.standard.bool(forKey: "DuckPet_EnableSystemReactions")
        }
    }

    public func setFocusTask(_ task: String) {
        focusTask = task
        if task.isEmpty {
            UserDefaults.standard.removeObject(forKey: "DuckPet_FocusTask")
        } else {
            UserDefaults.standard.set(task, forKey: "DuckPet_FocusTask")
        }
    }

    public var fullTrackInfo: String {
        if currentTrack.isEmpty { return "" }
        if currentArtist.isEmpty { return currentTrack }
        return "\(currentTrack) • \(currentArtist)"
    }
}
