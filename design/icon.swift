// Renders the app icon: `swift design/icon.swift` from the repo root.
// A white clock face with a blue wedge for the time left (25 of 60 minutes)
// and twelve hour ticks, on Apple's Mac template: an 824 pt rounded tile on a
// 1024 canvas with a soft shadow, in a blue gradient from top to bottom.
import SwiftUI
import AppKit

let tile: CGFloat = 824
let face = tile * 0.68

struct Wedge: Shape {
    var share: Double

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var path = Path()
        path.move(to: center)
        path.addArc(center: center, radius: rect.width / 2, startAngle: .degrees(-90),
                    endAngle: .degrees(-90 + 360 * share), clockwise: false)
        path.closeSubpath()
        return path
    }
}

struct Icon: View {
    let ink = Color(white: 0.15)

    var body: some View {
        ZStack {
            Color.clear
            RoundedRectangle(cornerRadius: tile * 0.225, style: .continuous)
                .fill(.linearGradient(
                    Gradient(colors: [Color(red: 0, green: 0.36, blue: 1), Color(red: 0.1, green: 0.75, blue: 0.95)])
                        .colorSpace(.perceptual),
                    startPoint: .top, endPoint: .bottom))
                .frame(width: tile, height: tile)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
            Circle().fill(.white).frame(width: face, height: face)
            Wedge(share: 25.0 / 60)
                .fill(Color(red: 0.05, green: 0.45, blue: 1))
                .frame(width: face * 0.8, height: face * 0.8)
            ForEach(0..<12) { hour in
                Capsule().fill(ink)
                    .frame(width: face * 0.022, height: face * (hour % 3 == 0 ? 0.075 : 0.045))
                    .offset(y: -face * 0.43)
                    .rotationEffect(.degrees(Double(hour) * 30))
            }
            Circle().fill(ink).frame(width: face * 0.07)
        }
        .frame(width: 1024, height: 1024)
    }
}

@MainActor func render(_ view: some View) -> NSBitmapImageRep {
    let renderer = ImageRenderer(content: view)
    renderer.scale = 1
    renderer.isOpaque = false
    return NSBitmapImageRep(data: renderer.nsImage!.tiffRepresentation!)!
}

func write(_ rep: NSBitmapImageRep, to path: String) {
    try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: path))
}

MainActor.assumeIsolated {
    let icon = render(Icon())
    let folder = "Assets.xcassets/AppIcon.appiconset"
    for points in [16, 32, 128, 256, 512] {
        for scale in [1, 2] {
            let pixels = points * scale
            let resized = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels,
                                           bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false,
                                           colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: resized)
            NSGraphicsContext.current?.imageInterpolation = .high
            icon.draw(in: NSRect(x: 0, y: 0, width: pixels, height: pixels))
            NSGraphicsContext.restoreGraphicsState()
            write(resized, to: "\(folder)/icon_\(points)x\(points)@\(scale)x.png")
        }
    }
}
