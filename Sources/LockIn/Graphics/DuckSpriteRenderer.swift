import AppKit

public class DuckSpriteRenderer {
    public static let shared = DuckSpriteRenderer()

    private var cache: [String: NSImage] = [:]
    public let spriteSize: CGFloat = 96.0
    public let spriteWidth: CGFloat = 96.0
    public let spriteHeight: CGFloat = 128.0
    private let canvasW: CGFloat = 24.0
    private let canvasH: CGFloat = 32.0
    private let headRoom: CGFloat = 8.0

    // Color Palette – Cute Vibrant Yellow Duck
    private let yellow     = NSColor(red: 1.00, green: 0.85, blue: 0.11, alpha: 1.0)
    private let yHi        = NSColor(red: 1.00, green: 0.96, blue: 0.51, alpha: 1.0) // crown highlight
    private let ySh        = NSColor(red: 0.90, green: 0.66, blue: 0.04, alpha: 1.0) // wing & warm shading
    private let beak       = NSColor(red: 1.00, green: 0.51, blue: 0.08, alpha: 1.0) // vibrant beak
    private let beakSh     = NSColor(red: 0.84, green: 0.37, blue: 0.02, alpha: 1.0) // beak shadow line
    private let eye        = NSColor(red: 0.11, green: 0.11, blue: 0.14, alpha: 1.0) // dark shiny eye
    private let shine      = NSColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0) // eye highlight
    private let cheek      = NSColor(red: 1.00, green: 0.47, blue: 0.59, alpha: 0.85) // rosy blush
    private let feet       = NSColor(red: 0.98, green: 0.43, blue: 0.06, alpha: 1.0) // webbed feet
    // Headphones
    private let hpBand     = NSColor(red: 0.14, green: 0.15, blue: 0.20, alpha: 1.0) // bold dark band
    private let hpPad      = NSColor(red: 0.20, green: 0.22, blue: 0.28, alpha: 1.0)
    private let hpNeon     = NSColor(red: 0.11, green: 0.84, blue: 0.38, alpha: 1.0) // Spotify neon green
    private let hpCyan     = NSColor(red: 0.00, green: 0.82, blue: 0.96, alpha: 1.0) // Cyber cyan
    // Keyboard Keys (for Bongo Duck typing)
    private let keyTop     = NSColor(red: 0.95, green: 0.96, blue: 0.98, alpha: 1.0)
    private let keyMid     = NSColor(red: 0.74, green: 0.76, blue: 0.82, alpha: 1.0)
    private let keySh      = NSColor(red: 0.52, green: 0.54, blue: 0.60, alpha: 1.0)
    // Water
    private let wLight     = NSColor(red: 0.44, green: 0.84, blue: 1.00, alpha: 0.90)
    private let wMid       = NSColor(red: 0.18, green: 0.63, blue: 0.94, alpha: 0.80)
    // Wardrobe Hats & Accessories Palette
    private let sunglassCol = NSColor(calibratedWhite: 0.08, alpha: 1.0)
    private let hatBrown    = NSColor(red: 0.55, green: 0.32, blue: 0.15, alpha: 1.0)
    private let hatDark     = NSColor(red: 0.38, green: 0.20, blue: 0.08, alpha: 1.0)
    private let hatBand     = NSColor(red: 0.85, green: 0.15, blue: 0.15, alpha: 1.0)
    private let crownGold   = NSColor(red: 1.0, green: 0.82, blue: 0.18, alpha: 1.0)
    private let crownSh     = NSColor(red: 0.85, green: 0.65, blue: 0.08, alpha: 1.0)
    private let crownRuby   = NSColor(red: 0.95, green: 0.20, blue: 0.25, alpha: 1.0)
    private let sproutGreen = NSColor(red: 0.25, green: 0.85, blue: 0.35, alpha: 1.0)
    private let sproutDark  = NSColor(red: 0.15, green: 0.60, blue: 0.25, alpha: 1.0)
    private let ninRed      = NSColor(red: 0.95, green: 0.20, blue: 0.25, alpha: 1.0)
    private let ninPlate    = NSColor(red: 0.85, green: 0.88, blue: 0.95, alpha: 1.0)
    private let wizPurp     = NSColor(red: 0.45, green: 0.20, blue: 0.75, alpha: 1.0)
    private let wizGold     = NSColor(red: 1.0, green: 0.85, blue: 0.20, alpha: 1.0)
    private let detBrown    = NSColor(red: 0.58, green: 0.44, blue: 0.32, alpha: 1.0)
    private let detDark     = NSColor(red: 0.40, green: 0.28, blue: 0.18, alpha: 1.0)
    private let strawYel    = NSColor(red: 0.92, green: 0.78, blue: 0.35, alpha: 1.0)
    private let strawRed    = NSColor(red: 0.88, green: 0.18, blue: 0.22, alpha: 1.0)
    private let strawSh     = NSColor(red: 0.75, green: 0.60, blue: 0.22, alpha: 1.0)
    private let hardYel     = NSColor(red: 1.0, green: 0.65, blue: 0.05, alpha: 1.0)
    private let hardSh      = NSColor(red: 0.85, green: 0.48, blue: 0.02, alpha: 1.0)
    // Mac Companion Palette
    private let plugBody    = NSColor(calibratedWhite: 0.20, alpha: 1.0)
    private let plugPin     = NSColor(calibratedWhite: 0.85, alpha: 1.0)
    private let plugWire    = NSColor(calibratedWhite: 0.30, alpha: 1.0)
    private let batRed      = NSColor(calibratedRed: 0.95, green: 0.25, blue: 0.25, alpha: 1.0)
    private let batFrame    = NSColor(calibratedWhite: 0.80, alpha: 1.0)
    private let sweatBlue   = NSColor(calibratedRed: 0.30, green: 0.70, blue: 1.0, alpha: 0.95)
    private let fanWood     = NSColor(calibratedRed: 0.65, green: 0.40, blue: 0.20, alpha: 1.0)
    private let fanPaper    = NSColor(calibratedRed: 0.92, green: 0.96, blue: 1.0, alpha: 1.0)
    private let fanBlue     = NSColor(calibratedRed: 0.20, green: 0.60, blue: 0.95, alpha: 1.0)
    private let breezeAir   = NSColor(calibratedWhite: 0.90, alpha: 0.70)

    private init() {}

    public func getFrame(
        action: DuckAction,
        tick: Int,
        facingLeft: Bool,
        isPlayingMusic: Bool,
        eyeOffsetX: CGFloat = 0.0,
        eyeOffsetY: CGFloat = 0.0,
        isTyping: Bool = false
    ) -> NSImage {
        let effAction: DuckAction
        if action == .pomodoro || DuckState.shared.isPomodoroActive {
            if isTyping {
                effAction = .typing
            } else {
                effAction = .pomodoro
            }
        } else if isTyping && action != .swimming && action != .swimLeft && action != .swimRight && action != .dragged {
            effAction = .typing
        } else {
            effAction = action
        }

        let isOverheat = DuckState.shared.isOverheating
        let f: Int
        switch effAction {
        case .typing:                          f = isOverheat ? ((tick / 1) % 2) : ((tick / 3) % 2)
        case .drinking:                        f = (tick / 8)  % 4
        case .pomodoro:                        f = (tick / 20) % 2
        case .vibeMusic:                       f = (tick / 7)  % 4
        case .swimming, .swimLeft, .swimRight: f = (tick / 10) % 4
        case .waddleLeft, .waddleRight:        f = (tick / 10) % 4
        case .climbing:                        f = (tick / 6)  % 4
        case .sleep:                           f = (tick / 24) % 4
        default:                               f = (tick / 12) % 4
        }

        let ex = Int(eyeOffsetX)
        let ey = Int(eyeOffsetY)
        let isNight = DuckState.shared.isNightTime
        let hat = DuckState.shared.currentHat
        let isLowBat = DuckState.shared.isLowBattery
        let isHighCpu = DuckState.shared.isHighCpu

        let key = "\(effAction.rawValue)_\(f)_\(facingLeft)_\(isPlayingMusic)_\(ex)_\(ey)_\(isOverheat)_\(isNight)_\(hat.rawValue)_\(isLowBat)_\(isHighCpu)"
        if let cached = cache[key] { return cached }

        let img = NSImage(size: NSSize(width: spriteWidth, height: spriteHeight))
        img.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            ctx.setShouldAntialias(false) // Crisp pixel art
            let s = spriteWidth / canvasW
            drawDuck(ctx: ctx, s: s, action: effAction, f: f,
                     facingLeft: facingLeft, isPlayingMusic: isPlayingMusic,
                     eyeOffX: eyeOffsetX, eyeOffY: eyeOffsetY, hat: hat,
                     isLowBat: isLowBat, isHighCpu: isHighCpu)
        }
        img.unlockFocus()
        cache[key] = img
        return img
    }

    public func clearCache() {
        cache.removeAll()
    }

    // Standard mirrored block drawer: automatically mirrors horizontally when facingLeft
    private func px(_ ctx: CGContext, _ x: CGFloat, _ y: CGFloat,
                    _ w: CGFloat, _ h: CGFloat, _ c: NSColor, _ s: CGFloat,
                    facingLeft: Bool) {
        let rx = facingLeft ? (canvasW - x - w) : x
        let ry = canvasH - (y + headRoom) - h
        ctx.setFillColor(c.cgColor)
        ctx.fill(CGRect(x: rx * s, y: ry * s, width: w * s, height: h * s))
    }

    // Absolute non-mirrored block drawer
    private func pxRaw(_ ctx: CGContext, _ x: CGFloat, _ y: CGFloat,
                       _ w: CGFloat, _ h: CGFloat, _ c: NSColor, _ s: CGFloat) {
        let ry = canvasH - (y + headRoom) - h
        ctx.setFillColor(c.cgColor)
        ctx.fill(CGRect(x: x * s, y: ry * s, width: w * s, height: h * s))
    }

    // Profile DJ Headphones (used when duck is side-facing)
    private func drawProfileHP(_ ctx: CGContext, s: CGFloat, oy: CGFloat, f: Int, facingLeft: Bool) {
        let glow = (f % 2 == 0) ? hpNeon : hpCyan
        px(ctx, 9, oy + 2, 4, 1, hpBand, s, facingLeft: facingLeft)
        px(ctx, 8, oy + 3, 1, 2, hpBand, s, facingLeft: facingLeft)
        px(ctx, 8, oy + 5, 3, 4, hpPad,  s, facingLeft: facingLeft)
        px(ctx, 9, oy + 6, 2, 2, glow,   s, facingLeft: facingLeft)
    }

    // Front-facing DJ Headphones with clear black arch across head
    private func drawFrontHP(_ ctx: CGContext, s: CGFloat, oy: CGFloat, glow: NSColor) {
        // Solid black headband arch over crown of head
        pxRaw(ctx, 7,  oy + 1, 10, 2, hpBand, s)
        pxRaw(ctx, 5,  oy + 2, 2,  3, hpBand, s)
        pxRaw(ctx, 17, oy + 2, 2,  3, hpBand, s)
        // Left & Right Earcups
        pxRaw(ctx, 3,  oy + 4, 3, 5, hpPad, s)
        pxRaw(ctx, 3,  oy + 5, 2, 3, glow,  s)
        pxRaw(ctx, 18, oy + 4, 3, 5, hpPad, s)
        pxRaw(ctx, 19, oy + 5, 2, 3, glow,  s)
    }

    // Classic single eighth note ♪ (oval notehead, vertical stem, curved flag)
    private func drawSingleNote(_ ctx: CGContext, s: CGFloat, ox: CGFloat, oy: CGFloat, c: NSColor) {
        // Oval note head
        pxRaw(ctx, ox + 0, oy + 4, 3, 1, c, s)
        pxRaw(ctx, ox + 1, oy + 5, 2, 1, c, s)
        // Stem
        pxRaw(ctx, ox + 2, oy + 1, 1, 3, c, s)
        // Flag
        pxRaw(ctx, ox + 3, oy + 1, 2, 1, c, s)
        pxRaw(ctx, ox + 4, oy + 2, 1, 1, c, s)
    }

    // Classic beamed double eighth note ♫ (two noteheads, two stems, top beam)
    private func drawDoubleNote(_ ctx: CGContext, s: CGFloat, ox: CGFloat, oy: CGFloat, c: NSColor) {
        // Left note head
        pxRaw(ctx, ox + 0, oy + 4, 2, 1, c, s)
        pxRaw(ctx, ox + 1, oy + 5, 2, 1, c, s)
        // Right note head
        pxRaw(ctx, ox + 4, oy + 4, 2, 1, c, s)
        pxRaw(ctx, ox + 5, oy + 5, 2, 1, c, s)
        // Stems
        pxRaw(ctx, ox + 2, oy + 1, 1, 3, c, s)
        pxRaw(ctx, ox + 6, oy + 1, 1, 3, c, s)
        // Top connecting beam
        pxRaw(ctx, ox + 2, oy + 0, 5, 2, c, s)
    }

    // ═════════════════════════════════════════════════════════
    // WARDROBE HATS PIXEL ART (10 Authentic 16-bit Styles)
    // ═════════════════════════════════════════════════════════
    private func drawHatFront(_ ctx: CGContext, s: CGFloat, oy: CGFloat, hat: DuckHat) {
        switch hat {
        case .none:
            break
        case .sunglasses:
            pxRaw(ctx, 7,  oy + 6, 4, 3, sunglassCol, s)
            pxRaw(ctx, 13, oy + 6, 4, 3, sunglassCol, s)
            pxRaw(ctx, 11, oy + 7, 2, 1, sunglassCol, s)
            pxRaw(ctx, 8,  oy + 7, 1, 1, shine, s)
            pxRaw(ctx, 14, oy + 7, 1, 1, shine, s)
        case .cowboy:
            pxRaw(ctx, 4,  oy + 4, 16, 1, hatBrown, s)
            pxRaw(ctx, 3,  oy + 3, 2,  1, hatDark,  s)
            pxRaw(ctx, 19, oy + 3, 2,  1, hatDark,  s)
            pxRaw(ctx, 7,  oy + 3, 10, 1, hatBand,  s)
            pxRaw(ctx, 7,  oy + 0, 10, 3, hatBrown, s)
            pxRaw(ctx, 9,  oy + 0, 6,  1, hatDark,  s)
        case .crown: // Royal Gold Crown with Sparkling Ruby
            pxRaw(ctx, 7,  oy + 3, 10, 2, crownSh,   s) // Gold base band
            pxRaw(ctx, 6,  oy + 0, 3,  3, crownGold, s) // Left spike
            pxRaw(ctx, 10, oy - 2, 4,  5, crownGold, s) // Center tall spike
            pxRaw(ctx, 15, oy + 0, 3,  3, crownGold, s) // Right spike
            pxRaw(ctx, 11, oy + 0, 2,  2, crownRuby, s) // Red Ruby Gem
        case .ninja:
            pxRaw(ctx, 6,  oy + 4, 12, 2, ninRed,   s)
            pxRaw(ctx, 10, oy + 4, 4,  2, ninPlate, s)
            pxRaw(ctx, 18, oy + 5, 3,  1, ninRed,   s)
            pxRaw(ctx, 20, oy + 6, 3,  1, ninRed,   s)
            pxRaw(ctx, 19, oy + 7, 3,  1, ninRed,   s)
        case .wizard: // TALL Wizard Hat (Towering Sorcerer Cone)
            pxRaw(ctx, 4,  oy + 4, 16, 1, wizPurp, s)
            pxRaw(ctx, 7,  oy + 2, 10, 2, wizPurp, s)
            pxRaw(ctx, 8,  oy + 0, 8,  2, wizPurp, s)
            pxRaw(ctx, 9,  oy - 2, 6,  2, wizPurp, s)
            pxRaw(ctx, 11, oy - 4, 4,  2, wizPurp, s)
            pxRaw(ctx, 14, oy - 5, 2,  2, wizPurp, s)
            pxRaw(ctx, 11, oy + 2, 2,  2, wizGold, s)
        case .detective:
            pxRaw(ctx, 5,  oy + 4, 14, 1, detDark,  s)
            pxRaw(ctx, 4,  oy + 4, 2,  1, detBrown, s)
            pxRaw(ctx, 18, oy + 4, 2,  1, detBrown, s)
            pxRaw(ctx, 7,  oy + 1, 10, 3, detBrown, s)
            pxRaw(ctx, 8,  oy + 0, 8,  1, detBrown, s)
            pxRaw(ctx, 9,  oy + 1, 2,  3, detDark,  s)
            pxRaw(ctx, 13, oy + 1, 2,  3, detDark,  s)
        case .straw:
            pxRaw(ctx, 3,  oy + 4, 18, 1, strawYel, s)
            pxRaw(ctx, 2,  oy + 5, 2,  1, strawSh,  s)
            pxRaw(ctx, 20, oy + 5, 2,  1, strawSh,  s)
            pxRaw(ctx, 7,  oy + 3, 10, 1, strawRed, s)
            pxRaw(ctx, 7,  oy + 0, 10, 3, strawYel, s)
        case .hardHat:
            pxRaw(ctx, 5,  oy + 4, 14, 1, hardSh,  s)
            pxRaw(ctx, 4,  oy + 4, 2,  1, hardYel, s)
            pxRaw(ctx, 6,  oy + 1, 12, 3, hardYel, s)
            pxRaw(ctx, 8,  oy + 0, 8,  1, hardYel, s)
            pxRaw(ctx, 11, oy - 1, 2,  5, hardSh,  s)
        case .sprout: // Kawaii Sprouting Plant
            pxRaw(ctx, 11, oy + 0, 2, 4, sproutDark,  s) // Stem
            pxRaw(ctx, 7,  oy - 2, 4, 3, sproutGreen, s) // Left leaf
            pxRaw(ctx, 8,  oy - 3, 3, 1, sproutGreen, s)
            pxRaw(ctx, 13, oy - 2, 4, 3, sproutGreen, s) // Right leaf
            pxRaw(ctx, 13, oy - 3, 3, 1, sproutGreen, s)
        }
    }

    private func drawHatProfile(_ ctx: CGContext, s: CGFloat, oy: CGFloat, hat: DuckHat, facingLeft: Bool) {
        switch hat {
        case .none:
            break
        case .sunglasses:
            px(ctx, 11, oy + 5, 4, 3, sunglassCol, s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 6, 3, 1, sunglassCol, s, facingLeft: facingLeft)
            px(ctx, 12, oy + 6, 1, 1, shine,       s, facingLeft: facingLeft)
        case .cowboy:
            px(ctx, 6,  oy + 4, 13, 1, hatBrown, s, facingLeft: facingLeft)
            px(ctx, 18, oy + 3, 2,  1, hatDark,  s, facingLeft: facingLeft)
            px(ctx, 5,  oy + 3, 2,  1, hatDark,  s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 3, 8,  1, hatBand,  s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 0, 8,  3, hatBrown, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 0, 4,  1, hatDark,  s, facingLeft: facingLeft)
        case .crown: // Royal Gold Crown (Profile)
            px(ctx, 8,  oy + 3, 8, 2, crownSh,   s, facingLeft: facingLeft) // Base band
            px(ctx, 7,  oy + 0, 2, 3, crownGold, s, facingLeft: facingLeft) // Back spike
            px(ctx, 11, oy - 2, 3, 5, crownGold, s, facingLeft: facingLeft) // Tall center spike
            px(ctx, 14, oy + 0, 2, 3, crownGold, s, facingLeft: facingLeft) // Front spike
            px(ctx, 11, oy + 0, 2, 2, crownRuby, s, facingLeft: facingLeft) // Ruby
        case .ninja:
            px(ctx, 7,  oy + 4, 9, 2, ninRed,   s, facingLeft: facingLeft)
            px(ctx, 11, oy + 4, 3, 2, ninPlate, s, facingLeft: facingLeft)
            px(ctx, 5,  oy + 5, 3, 1, ninRed,   s, facingLeft: facingLeft)
            px(ctx, 3,  oy + 6, 3, 1, ninRed,   s, facingLeft: facingLeft)
            px(ctx, 2,  oy + 7, 2, 1, ninRed,   s, facingLeft: facingLeft)
        case .wizard: // TALL Wizard (Profile)
            px(ctx, 6,  oy + 4, 13, 1, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 7,  oy + 2, 10, 2, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 7,  oy + 0, 8,  2, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 6,  oy - 2, 7,  2, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 5,  oy - 4, 5,  2, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 3,  oy - 5, 3,  2, wizPurp, s, facingLeft: facingLeft)
            px(ctx, 12, oy + 2, 2,  2, wizGold, s, facingLeft: facingLeft)
        case .detective:
            px(ctx, 14, oy + 4, 4, 1, detDark,  s, facingLeft: facingLeft)
            px(ctx, 6,  oy + 4, 3, 1, detDark,  s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 1, 8, 3, detBrown, s, facingLeft: facingLeft)
            px(ctx, 9,  oy + 0, 6, 1, detBrown, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 1, 2, 3, detDark,  s, facingLeft: facingLeft)
            px(ctx, 13, oy + 1, 2, 3, detDark,  s, facingLeft: facingLeft)
            px(ctx, 11, oy + 0, 2, 1, detDark,  s, facingLeft: facingLeft)
        case .straw:
            px(ctx, 5,  oy + 4, 14, 1, strawYel, s, facingLeft: facingLeft)
            px(ctx, 4,  oy + 5, 2,  1, strawSh,  s, facingLeft: facingLeft)
            px(ctx, 18, oy + 5, 2,  1, strawSh,  s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 3, 8,  1, strawRed, s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 0, 8,  3, strawYel, s, facingLeft: facingLeft)
        case .hardHat:
            px(ctx, 15, oy + 4, 3, 1, hardYel, s, facingLeft: facingLeft)
            px(ctx, 7,  oy + 4, 9, 1, hardSh,  s, facingLeft: facingLeft)
            px(ctx, 7,  oy + 1, 9, 3, hardYel, s, facingLeft: facingLeft)
            px(ctx, 9,  oy + 0, 6, 1, hardYel, s, facingLeft: facingLeft)
            px(ctx, 10, oy - 1, 2, 5, hardSh,  s, facingLeft: facingLeft)
        case .sprout: // Kawaii Sprouting Plant (Profile)
            px(ctx, 11, oy + 0, 2, 4, sproutDark,  s, facingLeft: facingLeft) // Stem
            px(ctx, 7,  oy - 2, 4, 3, sproutGreen, s, facingLeft: facingLeft) // Back leaf
            px(ctx, 8,  oy - 3, 3, 1, sproutGreen, s, facingLeft: facingLeft)
            px(ctx, 13, oy - 1, 4, 3, sproutGreen, s, facingLeft: facingLeft) // Front leaf
        }
    }

    private func drawDuck(ctx: CGContext, s: CGFloat, action: DuckAction, f: Int,
                          facingLeft: Bool, isPlayingMusic: Bool,
                          eyeOffX: CGFloat, eyeOffY: CGFloat, hat: DuckHat,
                          isLowBat: Bool = false, isHighCpu: Bool = false) {

        let eoX = max(-1, min(1, Int(eyeOffX)))
        let eoY = max(-1, min(1, Int(eyeOffY)))

        // ═════════════════════════════════════════
        // POMODORO STUDY DUCK (Quiet, calm, focused)
        // ═════════════════════════════════════════
        if action == .pomodoro {
            let breath = (f % 2 == 0) ? 0.0 : 1.0
            let oy: CGFloat = 1.0 + breath

            // Front Head
            pxRaw(ctx, 8, oy + 3, 8,  1, yHi, s)
            pxRaw(ctx, 7, oy + 4, 10, 1, yHi, s)
            pxRaw(ctx, 6, oy + 5, 12, 5, yellow, s)

            // Natural clear face without study glasses

            // Eyes inside lenses (subtle cursor tracking)
            let eyeX1 = 8.0  + CGFloat(eoX) * 0.5
            let eyeX2 = 14.0 + CGFloat(eoX) * 0.5
            let eyeY  = oy + 7.0 + CGFloat(eoY) * 0.5
            pxRaw(ctx, eyeX1, eyeY, 2, 2, eye, s)
            pxRaw(ctx, eyeX1, eyeY, 1, 1, shine, s)
            pxRaw(ctx, eyeX2, eyeY, 2, 2, eye, s)
            pxRaw(ctx, eyeX2, eyeY, 1, 1, shine, s)

            // Rosy Cheeks
            pxRaw(ctx, 5,  oy + 8, 2, 1, cheek, s)
            pxRaw(ctx, 17, oy + 8, 2, 1, cheek, s)

            // Front Beak
            pxRaw(ctx, 10, oy + 7,  4, 1, beak, s)
            pxRaw(ctx, 9,  oy + 8,  6, 2, beak, s)
            pxRaw(ctx, 10, oy + 10, 4, 1, beakSh, s)

            // Draw Wardrobe Hat
            drawHatFront(ctx, s: s, oy: oy, hat: hat)

            // DJ Headphones drawn on top if listening to music
            if isPlayingMusic {
                let glow = (f % 2 == 0) ? hpNeon : hpCyan
                drawFrontHP(ctx, s: s, oy: oy, glow: glow)
            }

            // Chubby Front Body
            pxRaw(ctx, 6, oy + 10, 12, 1, yellow, s)
            pxRaw(ctx, 5, oy + 11, 14, 5, yellow, s)
            pxRaw(ctx, 6, oy + 16, 12, 1, ySh, s)
            pxRaw(ctx, 7, oy + 17, 10, 1, ySh, s)

            // Folded wings resting politely
            pxRaw(ctx, 4, oy + 11, 2, 4, ySh, s)
            pxRaw(ctx, 18, oy + 11, 2, 4, ySh, s)

            // Feet resting in front
            pxRaw(ctx, 7,  oy + 18, 3, 1, feet, s)
            pxRaw(ctx, 14, oy + 18, 3, 1, feet, s)
            return
        }

        // ═════════════════════════════════════════
        // HYDRATION DRINKING DUCK (Happy sip with water cup)
        // ═════════════════════════════════════════
        if action == .drinking {
            let oy: CGFloat = 1.0
            let cupColor = NSColor(red: 0.20, green: 0.72, blue: 0.92, alpha: 1.0)
            let waterShine = NSColor(red: 0.75, green: 0.94, blue: 1.0, alpha: 1.0)

            // Front Head
            pxRaw(ctx, 8, oy + 3, 8,  1, yHi, s)
            pxRaw(ctx, 7, oy + 4, 10, 1, yHi, s)
            pxRaw(ctx, 6, oy + 5, 12, 5, yellow, s)

            // Happy closed eyes ^  ^
            pxRaw(ctx, 8,  oy + 7, 2, 1, eye, s)
            pxRaw(ctx, 7,  oy + 8, 1, 1, eye, s)
            pxRaw(ctx, 14, oy + 7, 2, 1, eye, s)
            pxRaw(ctx, 16, oy + 8, 1, 1, eye, s)

            // Rosy Cheeks
            pxRaw(ctx, 5,  oy + 8, 2, 1, cheek, s)
            pxRaw(ctx, 17, oy + 8, 2, 1, cheek, s)

            // Front Beak
            pxRaw(ctx, 10, oy + 7, 4, 2, beak, s)
            pxRaw(ctx, 10, oy + 9, 4, 1, beakSh, s)

            // Draw Wardrobe Hat
            drawHatFront(ctx, s: s, oy: oy, hat: hat)

            // Chubby Body
            pxRaw(ctx, 6, oy + 10, 12, 1, yellow, s)
            pxRaw(ctx, 5, oy + 11, 14, 5, yellow, s)
            pxRaw(ctx, 6, oy + 16, 12, 1, ySh, s)
            pxRaw(ctx, 7, oy + 17, 10, 1, ySh, s)

            // Holding mini blue water mug in front
            pxRaw(ctx, 9,  oy + 11, 6, 5, cupColor, s)
            pxRaw(ctx, 10, oy + 11, 4, 1, waterShine, s)
            pxRaw(ctx, 15, oy + 12, 2, 3, cupColor, s) // mug handle

            // Wings holding mug
            pxRaw(ctx, 7,  oy + 12, 2, 3, ySh, s)
            pxRaw(ctx, 13, oy + 12, 2, 3, ySh, s)

            // Feet
            pxRaw(ctx, 7,  oy + 18, 3, 1, feet, s)
            pxRaw(ctx, 14, oy + 18, 3, 1, feet, s)

            // Floating water droplet / sparkle
            let dropBob = CGFloat(f % 3)
            pxRaw(ctx, 11, max(1, oy + 9 - dropBob), 2, 2, waterShine, s)

            if isPlayingMusic {
                drawFrontHP(ctx, s: s, oy: oy, glow: hpCyan)
            }
            return
        }


        // ═════════════════════════════════════════
        // 1. BONGO DUCK TYPING (Faces US, turns SPICY RED if overheated!)
        // ═════════════════════════════════════════
        if action == .typing {
            let isOverheat = DuckState.shared.isOverheating
            let curYHi    = isOverheat ? NSColor(red: 1.0,  green: 0.45, blue: 0.35, alpha: 1.0) : yHi
            let curYellow = isOverheat ? NSColor(red: 0.96, green: 0.22, blue: 0.18, alpha: 1.0) : yellow
            let curYSh    = isOverheat ? NSColor(red: 0.76, green: 0.12, blue: 0.12, alpha: 1.0) : ySh
            let curBeak   = isOverheat ? NSColor(red: 1.0,  green: 0.55, blue: 0.15, alpha: 1.0) : beak

            let leftDown = (f % 2 == 0)
            let headBob: CGFloat = leftDown ? 0.0 : 1.0
            let oy = headBob

            // Front Head (x=6..17, y=3..9)
            pxRaw(ctx, 8, oy + 3, 8,  1, curYHi, s)
            pxRaw(ctx, 7, oy + 4, 10, 1, curYHi, s)
            pxRaw(ctx, 6, oy + 5, 12, 5, curYellow, s)

            // Two Big Cute Eyes looking at keys / user with subtle tracking
            let eyeY = oy + 7.0 + max(0.0, CGFloat(eoY) * 0.5)
            pxRaw(ctx, 8  + CGFloat(eoX) * 0.5, eyeY, 2, 2, eye, s)
            pxRaw(ctx, 8  + CGFloat(eoX) * 0.5, eyeY, 1, 1, shine, s)
            pxRaw(ctx, 14 + CGFloat(eoX) * 0.5, eyeY, 2, 2, eye, s)
            pxRaw(ctx, 14 + CGFloat(eoX) * 0.5, eyeY, 1, 1, shine, s)

            // Rosy Cheeks (fiery glow if overheating)
            let cheekCol = isOverheat ? NSColor(red: 1.0, green: 0.75, blue: 0.25, alpha: 0.95) : cheek
            pxRaw(ctx, 6,  oy + 8, 2, 1, cheekCol, s)
            pxRaw(ctx, 16, oy + 8, 2, 1, cheekCol, s)

            if isOverheat {
                // Pixel sweat drop on right temple (blue with white sparkle)
                let swX: CGFloat = 17.0
                let swY = oy + 4.0
                pxRaw(ctx, swX + 1, swY,     1, 1, NSColor(red: 0.20, green: 0.65, blue: 1.0, alpha: 1.0), s)
                pxRaw(ctx, swX,     swY + 1, 2, 2, NSColor(red: 0.15, green: 0.50, blue: 0.95, alpha: 1.0), s)
                pxRaw(ctx, swX,     swY + 1, 1, 1, NSColor.white, s)
            }

            // Cute Front Beak
            pxRaw(ctx, 10, oy + 7,  4, 1, curBeak, s)
            pxRaw(ctx, 9,  oy + 8,  6, 2, curBeak, s)
            pxRaw(ctx, 10, oy + 10, 4, 1, beakSh, s)

            // Draw Wardrobe Hat
            drawHatFront(ctx, s: s, oy: oy, hat: hat)

            // DJ Headphones drawn ON TOP with prominent black arch if music playing
            if isPlayingMusic {
                let glow = leftDown ? hpNeon : hpCyan
                drawFrontHP(ctx, s: s, oy: oy, glow: glow)
            }

            // Chubby Front Body
            pxRaw(ctx, 6, oy + 10, 12, 1, curYellow, s)
            pxRaw(ctx, 5, oy + 11, 14, 5, curYellow, s)
            pxRaw(ctx, 6, oy + 16, 12, 1, curYSh, s)
            pxRaw(ctx, 7, oy + 17, 10, 1, curYSh, s)

            // Feet
            pxRaw(ctx, 7,  oy + 18, 3, 1, feet, s)
            pxRaw(ctx, 14, oy + 18, 3, 1, feet, s)

            // Two Chunky Keyboard Keys in Front!
            let lKy: CGFloat = leftDown ? 17.0 : 16.0
            let rKy: CGFloat = leftDown ? 16.0 : 17.0

            // Left Key
            pxRaw(ctx, 3, lKy,     6, 1, keyTop, s)
            pxRaw(ctx, 3, lKy + 1, 6, 2, keyMid, s)
            pxRaw(ctx, 3, lKy + 3, 6, 1, keySh,  s)

            // Right Key
            pxRaw(ctx, 15, rKy,     6, 1, keyTop, s)
            pxRaw(ctx, 15, rKy + 1, 6, 2, keyMid, s)
            pxRaw(ctx, 15, rKy + 3, 6, 1, keySh,  s)

            // Bongo Wings (Alternating paws tapping keys!)
            if leftDown {
                // Left wing pressed down on key
                pxRaw(ctx, 4, oy + 12, 4, 3, curYellow, s)
                pxRaw(ctx, 4, lKy - 1, 4, 2, curYSh, s)
                // Right wing raised
                pxRaw(ctx, 16, oy + 11, 4, 3, curYSh, s)
                pxRaw(ctx, 17, oy + 13, 3, 2, curYellow, s)
            } else {
                // Left wing raised
                pxRaw(ctx, 4, oy + 11, 4, 3, curYSh, s)
                pxRaw(ctx, 4, oy + 13, 3, 2, curYellow, s)
                // Right wing pressed down on key
                pxRaw(ctx, 16, oy + 12, 4, 3, curYellow, s)
                pxRaw(ctx, 16, rKy - 1, 4, 2, curYSh, s)
            }
            return
        }

        // ═════════════════════════════════════════
        // 2. FRONT-FACING DJ DANCE (Faces US, grooving with headphones!)
        // ═════════════════════════════════════════
        if action == .vibeMusic || (isPlayingMusic && action == .idle) {
            let beat = f % 4
            let headBob: CGFloat = (beat == 0 || beat == 2) ? 1.0 : 0.0
            let oy = headBob

            let glow = (beat % 2 == 0) ? hpNeon : hpCyan

            // Front Head (x=6..17, y=3..9)
            pxRaw(ctx, 8, oy + 3, 8,  1, yHi, s)
            pxRaw(ctx, 7, oy + 4, 10, 1, yHi, s)
            pxRaw(ctx, 6, oy + 5, 12, 5, yellow, s)

            // Dancing Eyes: joyful open / happy smile wink ^_^
            if beat == 0 || beat == 2 {
                let eyeY = oy + 6.0 + CGFloat(eoY) * 0.5
                let leftEyeX  = 8.0  + CGFloat(eoX) * 0.5
                let rightEyeX = 14.0 + CGFloat(eoX) * 0.5
                pxRaw(ctx, leftEyeX,  eyeY, 2, 2, eye, s)
                pxRaw(ctx, leftEyeX,  eyeY, 1, 1, shine, s)
                pxRaw(ctx, rightEyeX, eyeY, 2, 2, eye, s)
                pxRaw(ctx, rightEyeX, eyeY, 1, 1, shine, s)
            } else {
                // Happy smiling eyes ^ _ ^
                pxRaw(ctx, 8,  oy + 6, 2, 1, eye, s)
                pxRaw(ctx, 14, oy + 6, 2, 1, eye, s)
            }

            // Rosy Cheeks (warmer if overheating)
            let cheekCol = DuckState.shared.isOverheating ? NSColor(red: 1.0, green: 0.30, blue: 0.25, alpha: 0.95) : cheek
            pxRaw(ctx, 6,  oy + 8, 2, 1, cheekCol, s)
            pxRaw(ctx, 16, oy + 8, 2, 1, cheekCol, s)

            if DuckState.shared.isOverheating {
                // Pixel sweat drop on right temple (blue with white sparkle)
                let swX: CGFloat = 17.0
                let swY = oy + 4.0
                pxRaw(ctx, swX + 1, swY,     1, 1, NSColor(red: 0.20, green: 0.65, blue: 1.0, alpha: 1.0), s)
                pxRaw(ctx, swX,     swY + 1, 2, 2, NSColor(red: 0.15, green: 0.50, blue: 0.95, alpha: 1.0), s)
                pxRaw(ctx, swX,     swY + 1, 1, 1, NSColor.white, s)
            }

            // Front Beak
            pxRaw(ctx, 10, oy + 7,  4, 1, beak, s)
            pxRaw(ctx, 9,  oy + 8,  6, 2, beak, s)
            pxRaw(ctx, 10, oy + 10, 4, 1, beakSh, s)

            // Draw Wardrobe Hat
            drawHatFront(ctx, s: s, oy: oy, hat: hat)

            // Symmetrical DJ Headphones with prominent black arch ON TOP of head
            drawFrontHP(ctx, s: s, oy: oy, glow: glow)

            // Chubby Front Body
            pxRaw(ctx, 6, oy + 10, 12, 1, yellow, s)
            pxRaw(ctx, 5, oy + 11, 14, 5, yellow, s)
            pxRaw(ctx, 6, oy + 16, 12, 1, ySh, s)
            pxRaw(ctx, 7, oy + 17, 10, 1, ySh, s)

            // Grooving Dancing Wings (swaying left & right with the beat!)
            if beat == 0 {
                // Left wing up, right wing down
                pxRaw(ctx, 3,  oy + 10, 3, 4, ySh, s)
                pxRaw(ctx, 17, oy + 13, 3, 4, ySh, s)
            } else if beat == 1 {
                // Wings centered
                pxRaw(ctx, 3,  oy + 11, 3, 4, ySh, s)
                pxRaw(ctx, 18, oy + 11, 3, 4, ySh, s)
            } else if beat == 2 {
                // Left wing down, right wing up
                pxRaw(ctx, 4,  oy + 13, 3, 4, ySh, s)
                pxRaw(ctx, 18, oy + 10, 3, 4, ySh, s)
            } else {
                // Wings wide
                pxRaw(ctx, 2,  oy + 11, 3, 4, ySh, s)
                pxRaw(ctx, 19, oy + 11, 3, 4, ySh, s)
            }

            // Tapping feet
            let tap: CGFloat = (beat % 2 == 0) ? 1.0 : -1.0
            pxRaw(ctx, 7,  oy + 18 + tap, 3, 1, feet, s)
            pxRaw(ctx, 14, oy + 18 - tap, 3, 1, feet, s)

            // Real iconic music notes (alternating ♪ and ♫)
            let ny = oy - CGFloat(beat % 3)
            if beat == 0 {
                drawSingleNote(ctx, s: s, ox: 18, oy: ny + 1, c: glow)
            } else if beat == 1 {
                drawDoubleNote(ctx, s: s, ox: 0,  oy: ny + 1, c: glow)
            } else if beat == 2 {
                drawSingleNote(ctx, s: s, ox: 1,  oy: ny + 1, c: glow)
            } else {
                drawDoubleNote(ctx, s: s, ox: 17, oy: ny + 1, c: glow)
            }
            return
        }

        // ═════════════════════════════════════════
        // 3. SWIMMING IN POND
        // ═════════════════════════════════════════
        if action == .swimming || action == .swimLeft || action == .swimRight {
            let bob: CGFloat = (f % 2 == 0) ? 0.0 : 1.0
            let oy: CGFloat = 2.0 + bob

            // Head
            px(ctx, 10, oy + 3, 5, 1, yHi, s, facingLeft: facingLeft)
            px(ctx, 9,  oy + 4, 7, 1, yHi, s, facingLeft: facingLeft)
            px(ctx, 8,  oy + 5, 8, 5, yellow, s, facingLeft: facingLeft)

            // Eye looking at cursor
            let effEoX = facingLeft ? -eoX : eoX
            let eyeX = 12.0 + CGFloat(effEoX)
            let eyeY = oy + 6.0 + CGFloat(eoY)
            px(ctx, eyeX, eyeY, 2, 2, eye, s, facingLeft: facingLeft)
            px(ctx, eyeX, eyeY, 1, 1, shine, s, facingLeft: facingLeft)

            // Cheek & Beak
            px(ctx, 10, oy + 8, 2, 1, cheek, s, facingLeft: facingLeft)
            px(ctx, 15, oy + 7, 4, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 15, oy + 8, 4, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 16, oy + 9, 2, 1, beakSh, s, facingLeft: facingLeft)

            // Draw Wardrobe Hat
            drawHatProfile(ctx, s: s, oy: oy, hat: hat, facingLeft: facingLeft)

            // Floating Body
            px(ctx, 5, oy + 10, 9, 1, yellow, s, facingLeft: facingLeft)
            px(ctx, 3, oy + 11, 12, 3, yellow, s, facingLeft: facingLeft)
            px(ctx, 2, oy + 10, 2, 2, yellow, s, facingLeft: facingLeft) // tail
            px(ctx, 1, oy + 9,  2, 2, yHi,    s, facingLeft: facingLeft)
            px(ctx, 5, oy + 11, 5, 2, ySh,    s, facingLeft: facingLeft) // wing

            // Water ripple waves
            let rip = CGFloat(f % 3)
            pxRaw(ctx, 1, oy + 13, 22, 2, wLight, s)
            pxRaw(ctx, 3, oy + 15, 18, 1, wMid, s)
            pxRaw(ctx, max(0, 1 - rip), oy + 13, 2, 1, wLight, s)
            pxRaw(ctx, min(22, 21 + rip), oy + 13, 2, 1, wLight, s)

            if isPlayingMusic {
                drawProfileHP(ctx, s: s, oy: oy, f: f, facingLeft: facingLeft)
                let glow = (f % 2 == 0) ? hpNeon : hpCyan
                if f % 2 == 0 {
                    drawSingleNote(ctx, s: s, ox: facingLeft ? 1 : 18, oy: 1 - CGFloat(f % 3), c: glow)
                } else {
                    drawDoubleNote(ctx, s: s, ox: facingLeft ? 0 : 17, oy: 1 - CGFloat(f % 3), c: glow)
                }
            }
            return
        }

        // ═════════════════════════════════════════
        // 4. SLEEPING
        // ═════════════════════════════════════════
        if action == .sleep {
            let oy: CGFloat = 2.0
            px(ctx, 10, oy + 5, 5, 1, yHi, s, facingLeft: facingLeft)
            px(ctx, 9,  oy + 6, 7, 5, yellow, s, facingLeft: facingLeft)
            px(ctx, 13, oy + 8, 2, 1, eye, s, facingLeft: facingLeft)
            px(ctx, 15, oy + 8, 3, 2, beak, s, facingLeft: facingLeft)
            drawHatProfile(ctx, s: s, oy: oy + 2.0, hat: hat, facingLeft: facingLeft)

            px(ctx, 4, oy + 9,  12, 7, yellow, s, facingLeft: facingLeft)
            px(ctx, 5, oy + 16, 10, 1, ySh,    s, facingLeft: facingLeft)
            px(ctx, 2, oy + 11, 2,  2, yellow, s, facingLeft: facingLeft)
            px(ctx, 7, oy + 10, 6,  4, ySh,    s, facingLeft: facingLeft)

            px(ctx, 6,  oy + 17, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 17, 3, 1, feet, s, facingLeft: facingLeft)

            let zy = oy - CGFloat(f % 4)
            let zc = NSColor(red: 0.62, green: 0.68, blue: 0.82, alpha: 0.85)
            px(ctx, 18, zy + 4, 3, 1, zc, s, facingLeft: facingLeft)
            px(ctx, 20, zy + 5, 1, 1, zc, s, facingLeft: facingLeft)
            px(ctx, 18, zy + 6, 3, 1, zc, s, facingLeft: facingLeft)
            return
        }

        // ═════════════════════════════════════════
        // 5. PECKING
        // ═════════════════════════════════════════
        if action == .peck {
            let oy: CGFloat = 1.0
            let dip: CGFloat = (f % 2 == 0) ? 1.5 : 0.0

            px(ctx, 1, oy + 8 - dip * 0.5, 2, 2, yHi,    s, facingLeft: facingLeft)
            px(ctx, 2, oy + 9 - dip * 0.5, 2, 2, yellow, s, facingLeft: facingLeft)

            px(ctx, 4, oy + 10, 11, 6, yellow, s, facingLeft: facingLeft)
            px(ctx, 5, oy + 16, 9,  1, ySh,    s, facingLeft: facingLeft)
            px(ctx, 6, oy + 11, 5,  4, ySh,    s, facingLeft: facingLeft)

            let hy = oy + 5.0 + dip
            px(ctx, 11, hy,     5, 1, yHi,    s, facingLeft: facingLeft)
            px(ctx, 10, hy + 1, 7, 5, yellow, s, facingLeft: facingLeft)

            px(ctx, 13, hy + 3, 2, 2, eye,   s, facingLeft: facingLeft)
            px(ctx, 13, hy + 3, 1, 1, shine, s, facingLeft: facingLeft)
            px(ctx, 12, hy + 4, 2, 1, cheek, s, facingLeft: facingLeft)

            px(ctx, 16, hy + 5, 3, 3, beak,   s, facingLeft: facingLeft)
            px(ctx, 17, hy + 7, 2, 1, beakSh, s, facingLeft: facingLeft)

            drawHatProfile(ctx, s: s, oy: hy - 3.0, hat: hat, facingLeft: facingLeft)

            px(ctx, 18, oy + 17, 1, 1, yHi,  s, facingLeft: facingLeft)
            px(ctx, 19, oy + 18, 1, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 17, oy + 18, 1, 1, yHi,  s, facingLeft: facingLeft)

            px(ctx, 6,  oy + 17, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 17, 3, 1, feet, s, facingLeft: facingLeft)

            if isPlayingMusic {
                drawProfileHP(ctx, s: s, oy: hy - 3.0, f: f, facingLeft: facingLeft)
            }
            return
        }

        // ═════════════════════════════════════════
        // 6. PREEN
        // ═════════════════════════════════════════
        if action == .preen {
            let oy: CGFloat = 1.0
            px(ctx, 5, oy + 10, 9,  1, yellow, s, facingLeft: facingLeft)
            px(ctx, 3, oy + 11, 12, 5, yellow, s, facingLeft: facingLeft)
            px(ctx, 4, oy + 16, 10, 1, ySh,    s, facingLeft: facingLeft)
            px(ctx, 2, oy + 10, 2,  2, yellow, s, facingLeft: facingLeft)
            px(ctx, 6, oy + 11, 6,  4, ySh,    s, facingLeft: facingLeft)

            px(ctx, 8, oy + 4, 5, 1, yHi,    s, facingLeft: facingLeft)
            px(ctx, 7, oy + 5, 7, 5, yellow, s, facingLeft: facingLeft)
            px(ctx, 9, oy + 7, 2, 1, eye,    s, facingLeft: facingLeft)
            px(ctx, 6, oy + 8, 3, 2, beak,   s, facingLeft: facingLeft)
            drawHatProfile(ctx, s: s, oy: oy + 1.0, hat: hat, facingLeft: facingLeft)

            px(ctx, 6,  oy + 17, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 17, 3, 1, feet, s, facingLeft: facingLeft)

            if isPlayingMusic {
                drawProfileHP(ctx, s: s, oy: oy + 1, f: f, facingLeft: facingLeft)
            }
            return
        }

        // ═════════════════════════════════════════
        // 7. STRETCH
        // ═════════════════════════════════════════
        if action == .stretch {
            let oy: CGFloat = 1.0
            pxRaw(ctx, 9, oy + 3, 6, 1, yHi, s)
            pxRaw(ctx, 8, oy + 4, 8, 6, yellow, s)
            pxRaw(ctx, 9,  oy + 6, 2, 1, eye, s)
            pxRaw(ctx, 13, oy + 6, 2, 1, eye, s)
            pxRaw(ctx, 10, oy + 7, 4, 2, beak, s)
            drawHatFront(ctx, s: s, oy: oy, hat: hat)

            pxRaw(ctx, 7, oy + 10, 10, 7, yellow, s)
            pxRaw(ctx, 8, oy + 16, 8,  1, ySh, s)

            let ws: CGFloat = (f % 2 == 0) ? 5 : 4
            pxRaw(ctx, 7 - ws, oy + 10, ws, 4, ySh, s)
            pxRaw(ctx, 17,     oy + 10, ws, 4, ySh, s)

            pxRaw(ctx, 8,  oy + 17, 3, 1, feet, s)
            pxRaw(ctx, 13, oy + 17, 3, 1, feet, s)
            return
        }

        // ═════════════════════════════════════════
        // 8. IDLE, WADDLE, DRAGGED, QUACK
        // ═════════════════════════════════════════
        let waddleBob: CGFloat = (action == .waddleLeft || action == .waddleRight) && (f % 2 == 0) ? 1.0 : ((action == .climbing) ? (CGFloat(f % 2) * 1.5) : 0.0)
        let oy = waddleBob

        // Head
        px(ctx, 10, oy + 3, 5, 1, yHi, s, facingLeft: facingLeft)
        px(ctx, 9,  oy + 4, 7, 1, yHi, s, facingLeft: facingLeft)
        px(ctx, 8,  oy + 5, 8, 5, yellow, s, facingLeft: facingLeft)

        // Eye tracking & Idle blink
        let effEoX = facingLeft ? -eoX : eoX
        let eyeX = 12.0 + CGFloat(effEoX)
        let effEoY = (action == .climbing) ? -1 : eoY
        let eyeY = oy + 6.0 + CGFloat(effEoY)

        let blink = (action == .idle && f == 0)
        if isLowBat {
            // Sleepy flat line eye (-_-)
            px(ctx, eyeX, eyeY + 1, 3, 1, eye, s, facingLeft: facingLeft)
        } else if blink {
            px(ctx, eyeX, eyeY + 1, 2, 1, eye, s, facingLeft: facingLeft)
        } else {
            px(ctx, eyeX, eyeY, 2, 2, eye, s, facingLeft: facingLeft)
            px(ctx, eyeX, eyeY, 1, 1, shine, s, facingLeft: facingLeft)
        }

        // Cheek
        px(ctx, 10, oy + 8, 2, 1, cheek, s, facingLeft: facingLeft)

        // Beak
        if action == .quack && (f % 2 == 0) {
            px(ctx, 15, oy + 6, 4, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 15, oy + 8, 4, 1, beak, s, facingLeft: facingLeft)
        } else {
            px(ctx, 15, oy + 7, 4, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 15, oy + 8, 4, 1, beak, s, facingLeft: facingLeft)
            px(ctx, 16, oy + 9, 2, 1, beakSh, s, facingLeft: facingLeft)
        }

        // Draw Wardrobe Hat
        drawHatProfile(ctx, s: s, oy: oy, hat: hat, facingLeft: facingLeft)

        // Chubby Body
        px(ctx, 5, oy + 10, 9,  1, yellow, s, facingLeft: facingLeft)
        px(ctx, 3, oy + 11, 12, 5, yellow, s, facingLeft: facingLeft)
        px(ctx, 4, oy + 16, 10, 1, ySh,    s, facingLeft: facingLeft)
        px(ctx, 5, oy + 17, 8,  1, ySh,    s, facingLeft: facingLeft)

        // Perky Tail
        px(ctx, 2, oy + 10, 2, 2, yellow, s, facingLeft: facingLeft)
        px(ctx, 1, oy + 9,  2, 2, yHi,    s, facingLeft: facingLeft)

        // Wing
        if action == .climbing {
            let climbFrame = f % 4
            if climbFrame == 0 || climbFrame == 2 {
                // Wing reaches high and forward
                px(ctx, 6, oy + 9,  5, 3, ySh,    s, facingLeft: facingLeft)
                px(ctx, 7, oy + 10, 3, 2, yellow, s, facingLeft: facingLeft)
            } else {
                // Wing pulls down to push body up
                px(ctx, 4, oy + 13, 5, 3, ySh,    s, facingLeft: facingLeft)
                px(ctx, 5, oy + 14, 3, 2, yellow, s, facingLeft: facingLeft)
            }
            // Little determination effort sparkle when climbing
            if f % 2 == 0 {
                px(ctx, 16, oy + 5, 1, 1, NSColor(red: 0.3, green: 0.7, blue: 1.0, alpha: 0.9), s, facingLeft: facingLeft)
            }
        } else {
            px(ctx, 5, oy + 12, 5, 3, ySh,    s, facingLeft: facingLeft)
            px(ctx, 6, oy + 13, 3, 2, yellow, s, facingLeft: facingLeft)
        }

        // Feet
        if action == .waddleLeft || action == .waddleRight {
            let st: CGFloat = (f % 2 == 0) ? 1.0 : -1.0
            px(ctx, 6,  oy + 18 + st, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 18 - st, 3, 1, feet, s, facingLeft: facingLeft)
        } else if action == .climbing {
            // Climbing scrambling feet: one foot steps up high, other grips below!
            let alt = (f % 2 == 0)
            let backFootY: CGFloat = alt ? 16.0 : 19.0
            let frontFootY: CGFloat = alt ? 19.0 : 16.0
            px(ctx, 5,  oy + backFootY,  3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 11, oy + frontFootY, 3, 1, feet, s, facingLeft: facingLeft)
        } else if action == .dragged {
            let dang: CGFloat = CGFloat(f % 2)
            px(ctx, 6,  oy + 18 + dang, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 19 - dang, 3, 1, feet, s, facingLeft: facingLeft)
        } else {
            px(ctx, 6,  oy + 18, 3, 1, feet, s, facingLeft: facingLeft)
            px(ctx, 10, oy + 18, 3, 1, feet, s, facingLeft: facingLeft)
        }

        // ── Mac Companion Props (Low Battery, Charging, High CPU) ──
        if isLowBat {
            // Plug in front of duck
            px(ctx, 16, oy + 12, 3, 3, plugBody, s, facingLeft: facingLeft)
            px(ctx, 19, oy + 12, 2, 1, plugPin,  s, facingLeft: facingLeft)
            px(ctx, 19, oy + 14, 2, 1, plugPin,  s, facingLeft: facingLeft)
            // Wire trailing to wing
            px(ctx, 14, oy + 13, 2, 1, plugWire, s, facingLeft: facingLeft)
            px(ctx, 11, oy + 14, 3, 1, plugWire, s, facingLeft: facingLeft)
            px(ctx, 9,  oy + 15, 2, 1, plugWire, s, facingLeft: facingLeft)

            // Floating Battery Indicator above tail (blinks gently)
            if (f % 4 != 0) {
                px(ctx, 2, oy + 2, 5, 1, batFrame, s, facingLeft: facingLeft)
                px(ctx, 2, oy + 5, 5, 1, batFrame, s, facingLeft: facingLeft)
                px(ctx, 2, oy + 3, 1, 2, batFrame, s, facingLeft: facingLeft)
                px(ctx, 6, oy + 3, 1, 2, batFrame, s, facingLeft: facingLeft)
                px(ctx, 7, oy + 3, 1, 1, batFrame, s, facingLeft: facingLeft)
                px(ctx, 3, oy + 3, 2, 2, batRed,   s, facingLeft: facingLeft)
            }
        } else if isHighCpu {
            // Sweat drop on cheek
            px(ctx, 11, oy + 5 + CGFloat(f % 2), 1, 2, sweatBlue, s, facingLeft: facingLeft)

            // Hand fan held by duck wing
            let fanY: CGFloat = (f % 2 == 0) ? 0.0 : 1.0
            px(ctx, 14, oy + 12 + fanY, 1, 3, fanWood,  s, facingLeft: facingLeft)
            px(ctx, 15, oy + 9  + fanY, 3, 4, fanPaper, s, facingLeft: facingLeft)
            px(ctx, 16, oy + 10 + fanY, 2, 2, fanBlue,  s, facingLeft: facingLeft)
            px(ctx, 18, oy + 8  + fanY, 2, 4, fanPaper, s, facingLeft: facingLeft)

            // Breeze air lines
            px(ctx, 19, oy + 5, 3, 1, breezeAir, s, facingLeft: facingLeft)
            px(ctx, 20, oy + 7, 2, 1, breezeAir, s, facingLeft: facingLeft)
        }

        // Profile headphones if music is playing while walking
        if isPlayingMusic {
            drawProfileHP(ctx, s: s, oy: oy, f: f, facingLeft: facingLeft)
            let glow = (f % 2 == 0) ? hpNeon : hpCyan
            drawSingleNote(ctx, s: s, ox: facingLeft ? 1 : 18, oy: 1 - CGFloat(f % 3), c: glow)
        }
    }

    // ═════════════════════════════════════════════════════════
    // POMODORO CHALKBOARD EASEL (Papan Timer)
    // ═════════════════════════════════════════════════════════
    public func drawPomodoroBoard(in rect: NSRect, mode: PomodoroMode, timeString: String, progress: CGFloat, isPaused: Bool) {
        guard let ctx = NSGraphicsContext.current?.cgContext else { return }
        ctx.saveGState()

        // 1. Ground Shadow under easel
        let shadowRect = NSRect(x: rect.minX + 8, y: rect.minY + 2, width: rect.width - 16, height: 7)
        let shadowPath = NSBezierPath(ovalIn: shadowRect)
        NSColor(calibratedWhite: 0.0, alpha: 0.20).setFill()
        shadowPath.fill()

        // 2. Wooden Easel Tripod Legs
        let woodDark = NSColor(red: 0.50, green: 0.28, blue: 0.12, alpha: 1.0)
        let woodLight = NSColor(red: 0.65, green: 0.38, blue: 0.18, alpha: 1.0)

        // Rear support leg
        let rearLeg = NSBezierPath()
        rearLeg.move(to: NSPoint(x: rect.midX, y: rect.minY + 68))
        rearLeg.line(to: NSPoint(x: rect.midX, y: rect.minY + 8))
        rearLeg.lineWidth = 3.5
        woodDark.setStroke()
        rearLeg.stroke()

        // Front left leg
        let leftLeg = NSBezierPath()
        leftLeg.move(to: NSPoint(x: rect.minX + 26, y: rect.minY + 48))
        leftLeg.line(to: NSPoint(x: rect.minX + 16, y: rect.minY + 5))
        leftLeg.lineWidth = 4.0
        leftLeg.lineCapStyle = .round
        woodLight.setStroke()
        leftLeg.stroke()

        // Front right leg
        let rightLeg = NSBezierPath()
        rightLeg.move(to: NSPoint(x: rect.maxX - 26, y: rect.minY + 48))
        rightLeg.line(to: NSPoint(x: rect.maxX - 16, y: rect.minY + 5))
        rightLeg.lineWidth = 4.0
        rightLeg.lineCapStyle = .round
        woodLight.setStroke()
        rightLeg.stroke()

        // 3. Wooden Chalkboard Outer Frame
        let frameRect = NSRect(x: rect.minX + 4, y: rect.minY + 20, width: rect.width - 8, height: rect.height - 24)
        let framePath = NSBezierPath(roundedRect: frameRect, xRadius: 8, yRadius: 8)
        woodLight.setFill()
        framePath.fill()

        woodDark.setStroke()
        framePath.lineWidth = 2.0
        framePath.stroke()

        // 4. Inner Dark Chalkboard
        let boardInner = frameRect.insetBy(dx: 5, dy: 5)
        let boardPath = NSBezierPath(roundedRect: boardInner, xRadius: 5, yRadius: 5)
        NSColor(red: 0.11, green: 0.13, blue: 0.17, alpha: 1.0).setFill()
        boardPath.fill()

        // Chalkboard inner border line
        NSColor(red: 0.18, green: 0.22, blue: 0.28, alpha: 0.8).setStroke()
        boardPath.lineWidth = 1.0
        boardPath.stroke()

        // 5. Wooden shelf ledge at bottom of frame
        let shelfRect = NSRect(x: frameRect.minX - 3, y: frameRect.minY - 2, width: frameRect.width + 6, height: 6)
        let shelfPath = NSBezierPath(roundedRect: shelfRect, xRadius: 2.5, yRadius: 2.5)
        woodDark.setFill()
        shelfPath.fill()

        // Tiny white piece of chalk on the shelf
        let chalkRect = NSRect(x: shelfRect.midX - 10, y: shelfRect.minY + 2, width: 8, height: 2.5)
        NSColor.white.withAlphaComponent(0.85).setFill()
        NSBezierPath(roundedRect: chalkRect, xRadius: 1, yRadius: 1).fill()

        // 6. Header: Mode title or PAUSED with authentic pixel sprite icon
        let headerText: String
        let headerColor: NSColor
        if isPaused {
            headerText = "PAUSED"
            headerColor = NSColor(red: 1.0, green: 0.78, blue: 0.28, alpha: 1.0)
        } else {
            headerText = mode.title
            headerColor = mode.badgeColor
        }

        let headerAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: headerColor
        ]
        let headerStr = NSAttributedString(string: headerText, attributes: headerAttrs)
        let headerSize = headerStr.size()

        let iconW: CGFloat = 11.0
        let iconSpacing: CGFloat = 4.0
        let totalHeaderW = iconW + iconSpacing + headerSize.width
        let startX = boardInner.midX - totalHeaderW / 2.0
        let headerY = boardInner.maxY - headerSize.height - 4.0

        ctx.saveGState()
        ctx.setShouldAntialias(false)
        if isPaused {
            drawMiniPause(ctx: ctx, at: CGPoint(x: startX, y: headerY + 1.0))
        } else {
            switch mode {
            case .focus:
                drawMiniTomato(ctx: ctx, at: CGPoint(x: startX, y: headerY + 1.0))
            case .shortBreak:
                drawMiniCoffee(ctx: ctx, at: CGPoint(x: startX, y: headerY + 1.0))
            case .longBreak:
                drawMiniPalm(ctx: ctx, at: CGPoint(x: startX, y: headerY + 1.0))
            }
        }
        ctx.restoreGState()

        let headerPoint = NSPoint(x: startX + iconW + iconSpacing, y: headerY)
        headerStr.draw(at: headerPoint)

        // 7. Time Countdown Text (Huge, crisp digital white)
        let timeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 20, weight: .heavy),
            .foregroundColor: NSColor.white
        ]
        let timeStr = NSAttributedString(string: timeString, attributes: timeAttrs)
        let timeSize = timeStr.size()
        let timePoint = NSPoint(x: boardInner.midX - timeSize.width / 2,
                                y: boardInner.midY - timeSize.height / 2 + 1)
        timeStr.draw(at: timePoint)

        // 8. Progress Bar at bottom of chalkboard
        let barW = boardInner.width - 12
        let barH: CGFloat = 5.0
        let barRect = NSRect(x: boardInner.minX + 6, y: boardInner.minY + 6, width: barW, height: barH)

        // Track
        let trackPath = NSBezierPath(roundedRect: barRect, xRadius: 2.5, yRadius: 2.5)
        NSColor(red: 0.18, green: 0.21, blue: 0.27, alpha: 1.0).setFill()
        trackPath.fill()

        // Fill
        let clampedProg = max(0.02, min(1.0, progress))
        let fillW = max(5.0, barW * clampedProg)
        let fillRect = NSRect(x: barRect.minX, y: barRect.minY, width: fillW, height: barH)
        let fillPath = NSBezierPath(roundedRect: fillRect, xRadius: 2.5, yRadius: 2.5)
        mode.badgeColor.setFill()
        fillPath.fill()

        ctx.restoreGState()
    }

    // ═════════════════════════════════════════════════════════
    // AUTHENTIC PIXEL SPRITES (No emojis!)
    // ═════════════════════════════════════════════════════════

    public func drawPixelHeart(ctx: CGContext, at point: CGPoint, scale: CGFloat = 2.0, alpha: CGFloat = 1.0) {
        let pattern: [(Int, Int, Int)] = [
            (1, 0, 0), (2, 0, 0), (4, 0, 0), (5, 0, 0),
            (0, 1, 0), (1, 1, 1), (2, 1, 0), (3, 1, 0), (4, 1, 0), (5, 1, 0), (6, 1, 2),
            (0, 2, 0), (1, 2, 0), (2, 2, 0), (3, 2, 0), (4, 2, 0), (5, 2, 0), (6, 2, 2),
            (1, 3, 0), (2, 3, 0), (3, 3, 0), (4, 3, 0), (5, 3, 2),
            (2, 4, 0), (3, 4, 0), (4, 4, 2),
            (3, 5, 2)
        ]
        let cPink = NSColor(red: 1.0, green: 0.35, blue: 0.58, alpha: alpha).cgColor
        let cWhite = NSColor(red: 1.0, green: 0.90, blue: 0.95, alpha: alpha).cgColor
        let cShadow = NSColor(red: 0.85, green: 0.15, blue: 0.40, alpha: alpha).cgColor

        for (c, r, ct) in pattern {
            let color = (ct == 1) ? cWhite : ((ct == 2) ? cShadow : cPink)
            ctx.setFillColor(color)
            let px = point.x + CGFloat(c) * scale
            let py = point.y + CGFloat(5 - r) * scale
            ctx.fill(CGRect(x: px, y: py, width: scale, height: scale))
        }
    }

    public func drawPixelWaterDrop(ctx: CGContext, at point: CGPoint, scale: CGFloat = 1.4, alpha: CGFloat = 1.0) {
        let dropPixels: [(Int, Int, Int)] = [
            (3, 0, 0),
            (2, 1, 0), (3, 1, 1), (4, 1, 0),
            (2, 2, 0), (3, 2, 2), (4, 2, 0),
            (1, 3, 0), (2, 3, 1), (3, 3, 1), (4, 3, 0), (5, 3, 0),
            (1, 4, 0), (2, 4, 1), (3, 4, 1), (4, 4, 0), (5, 4, 0),
            (1, 5, 0), (2, 5, 0), (3, 5, 0), (4, 5, 0), (5, 5, 0),
            (2, 6, 0), (3, 6, 0), (4, 6, 0)
        ]
        let cDeep = NSColor(red: 0.15, green: 0.50, blue: 0.95, alpha: alpha).cgColor
        let cCyan = NSColor(red: 0.45, green: 0.85, blue: 1.0, alpha: alpha).cgColor
        let cWhite = NSColor.white.withAlphaComponent(alpha).cgColor

        for (c, r, ct) in dropPixels {
            let col = (ct == 2) ? cWhite : ((ct == 1) ? cCyan : cDeep)
            ctx.setFillColor(col)
            let px = point.x + CGFloat(c) * scale
            let py = point.y + CGFloat(6 - r) * scale
            ctx.fill(CGRect(x: px, y: py, width: scale, height: scale))
        }
    }

    public func drawMiniTomato(ctx: CGContext, at point: CGPoint, s: CGFloat = 1.1) {
        let pixels: [(Int, Int, NSColor)] = [
            (3, 7, NSColor(red: 0.2, green: 0.85, blue: 0.2, alpha: 1)),
            (4, 7, NSColor(red: 0.3, green: 0.95, blue: 0.3, alpha: 1)),
            (2, 6, NSColor(red: 0.2, green: 0.75, blue: 0.2, alpha: 1)),
            (3, 6, NSColor(red: 0.2, green: 0.85, blue: 0.2, alpha: 1)),
            (4, 6, NSColor(red: 0.2, green: 0.75, blue: 0.2, alpha: 1)),
            (1, 5, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (2, 5, NSColor.white),
            (3, 5, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (4, 5, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (5, 5, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (1, 4, NSColor.white),
            (2, 4, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (3, 4, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (4, 4, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (5, 4, NSColor(red: 0.80, green: 0.18, blue: 0.15, alpha: 1)),
            (1, 3, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (2, 3, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (3, 3, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (4, 3, NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1)),
            (5, 3, NSColor(red: 0.80, green: 0.18, blue: 0.15, alpha: 1)),
            (2, 2, NSColor(red: 0.80, green: 0.18, blue: 0.15, alpha: 1)),
            (3, 2, NSColor(red: 0.80, green: 0.18, blue: 0.15, alpha: 1)),
            (4, 2, NSColor(red: 0.80, green: 0.18, blue: 0.15, alpha: 1))
        ]
        for (x, y, col) in pixels {
            ctx.setFillColor(col.cgColor)
            ctx.fill(CGRect(x: point.x + CGFloat(x) * s, y: point.y + CGFloat(y) * s, width: s, height: s))
        }
    }

    public func drawMiniCoffee(ctx: CGContext, at point: CGPoint, s: CGFloat = 1.1) {
        let steamCol = NSColor(red: 0.85, green: 0.90, blue: 0.95, alpha: 0.8)
        let cupCol = NSColor(red: 0.22, green: 0.78, blue: 0.65, alpha: 1.0)
        let cupSh = NSColor(red: 0.16, green: 0.62, blue: 0.52, alpha: 1.0)
        let pixels: [(Int, Int, NSColor)] = [
            (2, 7, steamCol), (4, 7, steamCol),
            (3, 6, steamCol),
            (1, 5, cupCol), (2, 5, cupCol), (3, 5, cupCol), (4, 5, cupCol), (5, 5, cupCol),
            (1, 4, cupCol), (2, 4, cupCol), (3, 4, cupCol), (4, 4, cupSh),  (5, 4, cupCol), (6, 4, cupCol),
            (1, 3, cupCol), (2, 3, cupCol), (3, 3, cupCol), (4, 3, cupSh),  (6, 3, cupCol),
            (1, 2, cupCol), (2, 2, cupCol), (3, 2, cupCol), (4, 2, cupSh),
            (2, 1, cupSh),  (3, 1, cupSh)
        ]
        for (x, y, col) in pixels {
            ctx.setFillColor(col.cgColor)
            ctx.fill(CGRect(x: point.x + CGFloat(x) * s, y: point.y + CGFloat(y) * s, width: s, height: s))
        }
    }

    public func drawMiniPalm(ctx: CGContext, at point: CGPoint, s: CGFloat = 1.1) {
        let green = NSColor(red: 0.25, green: 0.82, blue: 0.40, alpha: 1.0)
        let darkGreen = NSColor(red: 0.18, green: 0.65, blue: 0.30, alpha: 1.0)
        let trunk = NSColor(red: 0.68, green: 0.45, blue: 0.22, alpha: 1.0)
        let pixels: [(Int, Int, NSColor)] = [
            (1, 7, green), (3, 7, green), (5, 7, green),
            (2, 6, green), (3, 6, darkGreen), (4, 6, green),
            (1, 5, green), (3, 5, darkGreen), (5, 5, green),
            (3, 4, trunk),
            (3, 3, trunk),
            (4, 2, trunk),
            (3, 1, trunk), (4, 1, trunk), (5, 1, trunk)
        ]
        for (x, y, col) in pixels {
            ctx.setFillColor(col.cgColor)
            ctx.fill(CGRect(x: point.x + CGFloat(x) * s, y: point.y + CGFloat(y) * s, width: s, height: s))
        }
    }

    public func drawMiniPause(ctx: CGContext, at point: CGPoint, s: CGFloat = 1.1) {
        let pauseCol = NSColor(red: 1.0, green: 0.78, blue: 0.28, alpha: 1.0).cgColor
        ctx.setFillColor(pauseCol)
        ctx.fill(CGRect(x: point.x + 2 * s, y: point.y + 1 * s, width: 2.2 * s, height: 6.5 * s))
        ctx.fill(CGRect(x: point.x + 5.5 * s, y: point.y + 1 * s, width: 2.2 * s, height: 6.5 * s))
    }

    public func drawPixelTarget(ctx: CGContext, at point: CGPoint, s: CGFloat = 1.3) {
        let gold = NSColor(red: 1.0, green: 0.82, blue: 0.18, alpha: 1.0)
        let red = NSColor(red: 0.95, green: 0.28, blue: 0.22, alpha: 1.0)
        let white = NSColor.white
        let pixels: [(Int, Int, NSColor)] = [
            (2, 6, gold), (3, 6, gold), (4, 6, gold),
            (1, 5, gold), (3, 5, white), (5, 5, gold),
            (0, 4, gold), (2, 4, red), (3, 4, red), (4, 4, red), (6, 4, gold),
            (0, 3, gold), (1, 3, white), (2, 3, red), (3, 3, gold), (4, 3, red), (5, 3, white), (6, 3, gold),
            (0, 2, gold), (2, 2, red), (3, 2, red), (4, 2, red), (6, 2, gold),
            (1, 1, gold), (5, 1, gold),
            (2, 0, gold), (3, 0, gold), (4, 0, gold)
        ]
        for (x, y, col) in pixels {
            ctx.setFillColor(col.cgColor)
            ctx.fill(CGRect(x: point.x + CGFloat(x) * s, y: point.y + CGFloat(y) * s, width: s, height: s))
        }
    }

    public func drawPixelSmoke(ctx: CGContext, at point: CGPoint, tick: Int) {
        // Floating pixel smoke & heat sparks rising from typing paws/keys
        let smokeWhite = NSColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 0.85).cgColor
        let smokeGray  = NSColor(red: 0.70, green: 0.74, blue: 0.82, alpha: 0.65).cgColor
        let sparkGold  = NSColor(red: 1.0,  green: 0.78, blue: 0.18, alpha: 0.90).cgColor
        let sparkOrange = NSColor(red: 1.0, green: 0.35, blue: 0.12, alpha: 0.95).cgColor

        let puffs: [(CGFloat, CGFloat, Int)] = [
            (-12.0, 16.0, 0),
            (14.0,  15.0, 5),
            (-2.0,  22.0, 10)
        ]

        for (dx, dy, phase) in puffs {
            let cycle = (tick + phase) % 18
            let floatY = CGFloat(cycle) * 1.6
            let alpha = max(0.0, 1.0 - CGFloat(cycle) / 18.0)

            let px = point.x + dx + (cycle % 2 == 0 ? 1.0 : -1.0)
            let py = point.y + dy + floatY

            ctx.setFillColor(smokeWhite.copy(alpha: alpha)!)
            ctx.fill(CGRect(x: px, y: py, width: 3.5, height: 3.5))
            ctx.setFillColor(smokeGray.copy(alpha: alpha * 0.75)!)
            ctx.fill(CGRect(x: px - 1.0, y: py - 1.0, width: 2.5, height: 2.5))

            if cycle < 6 {
                let sparkCol = (cycle % 2 == 0) ? sparkOrange : sparkGold
                ctx.setFillColor(sparkCol.copy(alpha: alpha)!)
                ctx.fill(CGRect(x: px + 2.0, y: py - 2.0, width: 2.0, height: 2.0))
            }
        }
    }

    public func drawPixelFirefly(ctx: CGContext, at point: CGPoint, pulse: CGFloat) {
        let coreCol = NSColor(red: 1.0, green: 0.96, blue: 0.35, alpha: 0.95 * pulse).cgColor
        let glowCol = NSColor(red: 0.65, green: 0.95, blue: 0.25, alpha: 0.40 * pulse).cgColor

        // Outer glow
        ctx.setFillColor(glowCol)
        ctx.fill(CGRect(x: point.x - 2.0, y: point.y - 2.0, width: 6.0, height: 6.0))
        // Inner core
        ctx.setFillColor(coreCol)
        ctx.fill(CGRect(x: point.x, y: point.y, width: 2.0, height: 2.0))
    }

    public func drawPixelRaindrop(ctx: CGContext, at point: CGPoint, length: CGFloat = 7.0) {
        let rainCol = NSColor(red: 0.55, green: 0.82, blue: 1.0, alpha: 0.75).cgColor
        ctx.setFillColor(rainCol)
        ctx.fill(CGRect(x: point.x, y: point.y, width: 1.5, height: length))
    }
}
