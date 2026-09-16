import AppKit

public class SpeechBubbleView: NSView {
    public var text: String = "" {
        didSet {
            needsDisplay = true
        }
    }
    
    public var isMusic: Bool = false {
        didSet {
            needsDisplay = true
        }
    }

    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        guard !text.isEmpty else { return }

        guard NSGraphicsContext.current != nil else { return }

        let paddingH: CGFloat = 12.0
        let paddingV: CGFloat = 6.0

        let pStyle = NSMutableParagraphStyle()
        pStyle.alignment = .center
        pStyle.lineBreakMode = .byTruncatingTail

        let font = NSFont.systemFont(ofSize: 11, weight: .semibold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor(white: 0.98, alpha: 1.0),
            .paragraphStyle: pStyle
        ]

        let displayString = text
        let str = NSAttributedString(string: displayString, attributes: attrs)
        let strSize = str.size()

        let bubbleW = min(max(strSize.width + paddingH * 2, 80), bounds.width - 10)
        let bubbleH = strSize.height + paddingV * 2
        let bubbleX = (bounds.width - bubbleW) / 2.0
        let bubbleY = bounds.height - bubbleH - 2.0

        let bubbleRect = NSRect(x: bubbleX, y: bubbleY, width: bubbleW, height: bubbleH)
        let path = NSBezierPath(roundedRect: bubbleRect, xRadius: 8, yRadius: 8)

        // Dark sleek glass background
        let bgColor = isMusic 
            ? NSColor(red: 0.08, green: 0.10, blue: 0.16, alpha: 0.92)
            : NSColor(red: 0.06, green: 0.08, blue: 0.12, alpha: 0.90)
        bgColor.setFill()
        path.fill()

        // Border outline (Glowing Cyan / Emerald for Spotify)
        let borderColor = isMusic
            ? NSColor(red: 0.13, green: 0.77, blue: 0.36, alpha: 0.85) // Spotify Green
            : NSColor(red: 0.98, green: 0.80, blue: 0.08, alpha: 0.75) // Duck Yellow
        borderColor.setStroke()
        path.lineWidth = 1.2
        path.stroke()

        // Draw little speech triangle pointer at bottom center
        let pointer = NSBezierPath()
        pointer.move(to: NSPoint(x: bounds.width / 2.0 - 4, y: bubbleY))
        pointer.line(to: NSPoint(x: bounds.width / 2.0 + 4, y: bubbleY))
        pointer.line(to: NSPoint(x: bounds.width / 2.0, y: bubbleY - 4))
        pointer.close()
        bgColor.setFill()
        pointer.fill()

        // Draw Text perfectly centered
        let textRect = NSRect(
            x: bubbleX + paddingH,
            y: bubbleY + paddingV,
            width: bubbleW - paddingH * 2,
            height: strSize.height
        )
        str.draw(in: textRect)
    }
}
