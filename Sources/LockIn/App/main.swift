import AppKit

if CommandLine.arguments.contains("--export-hd-sprites") {
    let renderer = DuckSpriteRenderer.shared
    let currentDir = FileManager.default.currentDirectoryPath
    let outDir = (currentDir as NSString).appendingPathComponent("dist/Sprites")
    try? FileManager.default.createDirectory(atPath: outDir, withIntermediateDirectories: true)

    let targetScale: CGFloat = 4.0
    let targetW = Int(renderer.spriteWidth * targetScale)
    let targetH = Int(renderer.spriteHeight * targetScale)

    func saveHDImage(_ img: NSImage, filename: String) {
        guard let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: targetW,
            height: targetH,
            bitsPerComponent: 8,
            bytesPerRow: targetW * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        ctx.interpolationQuality = .none
        ctx.setShouldAntialias(false)
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: targetW, height: targetH))

        guard let upscaledCG = ctx.makeImage() else { return }
        let rep = NSBitmapImageRep(cgImage: upscaledCG)
        guard let pngData = rep.representation(using: .png, properties: [:]) else { return }
        let fileURL = URL(fileURLWithPath: "\(outDir)/\(filename)")
        try? pngData.write(to: fileURL)
    }

    func saveHDStrip(images: [NSImage], filename: String) {
        let totalW = targetW * images.count
        let totalH = targetH
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGContext(
            data: nil,
            width: totalW,
            height: totalH,
            bitsPerComponent: 8,
            bytesPerRow: totalW * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else { return }

        ctx.interpolationQuality = .none
        ctx.setShouldAntialias(false)

        for (i, img) in images.enumerated() {
            guard let cg = img.cgImage(forProposedRect: nil, context: nil, hints: nil) else { continue }
            let rect = CGRect(x: i * targetW, y: 0, width: targetW, height: targetH)
            ctx.draw(cg, in: rect)
        }

        guard let stripCG = ctx.makeImage() else { return }
        let rep = NSBitmapImageRep(cgImage: stripCG)
        guard let pngData = rep.representation(using: .png, properties: [:]) else { return }
        let fileURL = URL(fileURLWithPath: "\(outDir)/\(filename)")
        try? pngData.write(to: fileURL)
    }

    print("Exporting HD Sprites (384x512 per frame)...")

    let pomo = renderer.getFrame(action: .pomodoro, tick: 0, facingLeft: false, isPlayingMusic: false)
    saveHDImage(pomo, filename: "pomodoro_study_duck.png")

    let hats = DuckHat.allCases
    for (i, hat) in hats.enumerated() {
        DuckState.shared.currentHat = hat
        let num = String(format: "%02d", i + 1)
        let raw = hat.rawValue

        let front = renderer.getFrame(action: .pomodoro, tick: 0, facingLeft: false, isPlayingMusic: false)
        saveHDImage(front, filename: "wardrobe_\(num)_\(raw)_front.png")

        let side = renderer.getFrame(action: .idle, tick: 12, facingLeft: false, isPlayingMusic: false)
        saveHDImage(side, filename: "wardrobe_\(num)_\(raw)_side.png")

        saveHDStrip(images: [front, side], filename: "wardrobe_\(num)_\(raw)_pair.png")
    }
    DuckState.shared.currentHat = .none

    print("All front & wardrobe sprites exported successfully!")
    exit(0)
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
