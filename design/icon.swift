// Renders the app icon: `swift design/icon.swift` from the repo root.
// A white stopwatch (ring, crown, side button and one hand at 12) on Apple's
// Mac template: an 824 pt rounded tile on a 1024 canvas with a soft shadow,
// in a blue gradient from top to bottom.
import SwiftUI
import AppKit

let tile: CGFloat = 824

struct Icon: View {
    var body: some View {
        // Sizes as shares of the tile, so the drawing scales with it.
        let ring = tile * 0.54
        let stroke = tile * 0.065
        // The watch's middle sits a little below the tile's, to leave room
        // for the crown above it.
        let drop = tile * 0.05
        ZStack {
            Color.clear
            RoundedRectangle(cornerRadius: tile * 0.225, style: .continuous)
                .fill(.linearGradient(
                    Gradient(colors: [Color(red: 0, green: 0.36, blue: 1), Color(red: 0.1, green: 0.75, blue: 0.95)])
                        .colorSpace(.perceptual),
                    startPoint: .top, endPoint: .bottom))
                .frame(width: tile, height: tile)
                .shadow(color: .black.opacity(0.25), radius: 12, y: 8)
            ZStack {
                Circle().stroke(.white, lineWidth: stroke).frame(width: ring, height: ring)
                // Crown: a stem and a cap above 12 o'clock.
                Rectangle().fill(.white)
                    .frame(width: stroke, height: tile * 0.06)
                    .offset(y: -(ring / 2 + tile * 0.03))
                RoundedRectangle(cornerRadius: stroke / 3).fill(.white)
                    .frame(width: tile * 0.16, height: stroke)
                    .offset(y: -(ring / 2 + tile * 0.06 + stroke / 2))
                // Side button at half past one.
                RoundedRectangle(cornerRadius: stroke / 3).fill(.white)
                    .frame(width: stroke, height: tile * 0.08)
                    .offset(y: -(ring / 2 + tile * 0.05))
                    .rotationEffect(.degrees(45))
                // One hand, from the middle to 12.
                Capsule().fill(.white)
                    .frame(width: stroke, height: ring * 0.3)
                    .offset(y: -ring * 0.15)
                Circle().fill(.white).frame(width: stroke * 1.6)
            }
            .offset(y: drop)
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
