import AppKit

/// The menu bar image of a running timer: the time left, then an outlined bar
/// filled from the left for the share of time left. A template image, so it
/// follows the menu bar's light or dark look.
func progressBar(time: String, left share: Double) -> NSImage {
    let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.menuBarFont(ofSize: 0).pointSize, weight: .regular)
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
    let text = NSAttributedString(string: time, attributes: attributes)
    // Room for 00:00, with the time aligned right, so the bar stays in place
    // when 10:00 becomes 9:59. All digits have the same width in this font,
    // so 00:00 is as wide as any time with four digits; a timer of 100
    // minutes or more, after several Add 5 minutes, gets more room.
    let fourDigits = ceil(NSAttributedString(string: "00:00", attributes: attributes).size().width)
    let textWidth = max(fourDigits, ceil(text.size().width))
    // Whole points, so the outline and the fill land on pixel edges on any
    // display and the gap around the fill is the same on every side.
    let bar = NSSize(width: 36, height: 14)
    let line: CGFloat = 1
    let gap: CGFloat = 2
    let spacing: CGFloat = 4
    let size = NSSize(width: textWidth + spacing + bar.width, height: bar.height)
    let image = NSImage(size: size, flipped: false) { bounds in
        // The digits' middle, half their height above the baseline, on the
        // bar's middle.
        let baseline = ((bounds.height - font.capHeight) / 2).rounded()
        text.draw(at: NSPoint(x: textWidth - ceil(text.size().width), y: baseline + font.descender))
        NSColor.black.set()
        let frame = NSRect(x: textWidth + spacing, y: 0, width: bar.width, height: bar.height)
        let outline = frame.insetBy(dx: line / 2, dy: line / 2)
        let border = NSBezierPath(roundedRect: outline, xRadius: outline.height / 2, yRadius: outline.height / 2)
        border.lineWidth = line
        border.stroke()
        let track = frame.insetBy(dx: line + gap, dy: line + gap)
        NSBezierPath(roundedRect: track, xRadius: track.height / 2, yRadius: track.height / 2).addClip()
        // A straight edge on the right, so where the fill ends is easy to read.
        var fill = track
        fill.size.width = (track.width * min(max(share, 0), 1)).rounded()
        fill.fill()
        return true
    }
    image.isTemplate = true
    return image
}
