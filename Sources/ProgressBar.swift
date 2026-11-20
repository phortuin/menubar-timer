import AppKit

/// The menu bar image of a running timer: the time left, then an outlined bar
/// as long as the timer's `length` in seconds, filled solid from the left for
/// the `seconds` left and faint for the rest, the time gone. The bar and its
/// solid part are as wide as `barWidth` makes them, so a width means the same
/// time for every timer. A template image, so it follows the menu bar's light
/// or dark look.
func progressBar(time: String, left seconds: Int, of length: Int) -> NSImage {
    let font = NSFont.monospacedDigitSystemFont(ofSize: NSFont.menuBarFont(ofSize: 0).pointSize, weight: .regular)
    let attributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: NSColor.black]
    let text = NSAttributedString(string: time, attributes: attributes)
    // Room for 00:00, with the time aligned right, so the bar stays in place
    // when 10:00 becomes 9:59. All digits have the same width in this font,
    // so 00:00 is as wide as any time with four digits; a timer of 100
    // minutes or more, after several Add 5 minutes, gets more room.
    let fourDigits = ceil(NSAttributedString(string: "00:00", attributes: attributes).size().width)
    let textWidth = max(fourDigits, ceil(text.size().width))
    // Whole points, so the outline lands on pixel edges on any display.
    let line: CGFloat = 1
    let gap: CGFloat = 2
    let spacing: CGFloat = 4
    // The inside is as wide as the timer is long, in whole points, but never
    // shorter than 5 minutes: the bar of a shorter timer starts partly gone,
    // because a bar narrower than it is high no longer reads as a bar. Around
    // the inside come the gap and the outline.
    let bar = NSSize(width: ceil(barWidth(max(length, 5 * 60))) + 2 * (line + gap), height: 14)
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
        NSColor.black.withAlphaComponent(0.3).set()
        track.fill()
        // A straight edge on the right, so where the time left ends is easy
        // to read.
        var fill = track
        fill.size.width = barWidth(seconds)
        NSColor.black.set()
        fill.fill()
        return true
    }
    image.isTemplate = true
    return image
}
