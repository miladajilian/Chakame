// Composes App Store marketing screenshots from raw simulator captures.
// Usage: swift marketing/screenshots/compose.swift   (run from the repo root)
// Output: marketing/screenshots/iphone-6.3/*.png (1206x2622), marketing/screenshots/ipad-13/*.png (2064x2752)

import AppKit
import CoreText

let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let base = root.appendingPathComponent("marketing/screenshots")
let fontURL = root.appendingPathComponent("Chakame/Resources/Font/Vazirmatn-Regular.ttf")
CTFontManagerRegisterFontsForURL(fontURL as CFURL, .process, nil)

// MARK: - Palette (from the app icon)

func rgb(_ hex: UInt32, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(
        srgbRed: CGFloat((hex >> 16) & 0xFF) / 255,
        green: CGFloat((hex >> 8) & 0xFF) / 255,
        blue: CGFloat(hex & 0xFF) / 255,
        alpha: alpha
    )
}

let skyBlue = rgb(0x1BAEEE)
let royalBlue = rgb(0x1A6FE0)
let deepNavy = rgb(0x0B2A5B)
let gold = rgb(0xFFD27A)
let paper = rgb(0xF5F8FD)
let paper2 = rgb(0xE6EEFA)

enum Theme { case blue, light, navy }

struct Slide {
    let raw: String
    let title1: String
    let title2: String
    let subtitle: String
    let theme: Theme
    var hero = false
}

let slides: [Slide] = [
    Slide(
        raw: "04-poem",
        title1: "دیوان شاعران پارسی",
        title2: "در جیب شما",
        subtitle: "شعر کلاسیک فارسی را زیبا و آسوده بخوانید",
        theme: .blue,
        hero: true
    ),
    Slide(
        raw: "01-home",
        title1: "سخنوران بزرگ",
        title2: "در یک نگاه",
        subtitle: "فردوسی، مولانا، حافظ، خیام، سعدی و صدها شاعر دیگر",
        theme: .light
    ),
    Slide(
        raw: "02-poet",
        title1: "همهٔ آثار هر شاعر",
        title2: "مرتب و دسته‌بندی‌شده",
        subtitle: "غزلیات، رباعیات، قصاید، مثنوی و…",
        theme: .navy
    ),
    Slide(
        raw: "03-ghazals",
        title1: "۴۹۵ غزل حافظ",
        title2: "تنها با یک لمس",
        subtitle: "فهرست کامل اشعار هر دفتر",
        theme: .blue
    ),
    Slide(
        raw: "05-rubai",
        title1: "رباعیات خیام",
        title2: "خوش‌خوان و چشم‌نواز",
        subtitle: "با قلم وزیرمتن، ساخته‌شده برای خط فارسی",
        theme: .light
    ),
    Slide(
        raw: "07-golestan",
        title1: "گلستان سعدی",
        title2: "نثر و نظم در کنار هم",
        subtitle: "حکایت‌ها را همان‌گونه که نوشته شده‌اند بخوانید",
        theme: .navy
    ),
    Slide(
        raw: "06-copy",
        title1: "رونوشت یک مصراع",
        title2: "یا تمام ابیات",
        subtitle: "بیت محبوبتان را با دوستان به اشتراک بگذارید",
        theme: .blue
    ),
    Slide(
        raw: "08-favorites",
        title1: "شعرهای محبوب شما",
        title2: "همیشه دم دست",
        subtitle: "با یک لمس روی قلب نگهشان دارید، حتی بدون اینترنت",
        theme: .light
    ),
    Slide(
        raw: "09-search",
        title1: "شاعر دلخواهتان را",
        title2: "در یک لحظه بیابید",
        subtitle: "جستجوی سریع میان صدها سخنور پارسی‌گوی",
        theme: .navy
    ),
]

// MARK: - Device specs

struct Device {
    let folder: String
    let rawFolder: String
    let size: CGSize
    let deviceWidth: CGFloat // rendered width of the screen inside the frame
    let screenTop: CGFloat // y (from top) where the screen starts
    let screenCorner: CGFloat // corner radius of the screen, in canvas px
    let bezel: CGFloat
    let titleSize: CGFloat
    let subtitleSize: CGFloat
    let titleTop: CGFloat
    let iconSize: CGFloat
    let isPad: Bool
}

let iphone = Device(
    folder: "iphone-6.3",
    rawFolder: "raw/iphone",
    size: CGSize(width: 1206, height: 2622),
    deviceWidth: 930,
    screenTop: 790,
    screenCorner: 128,
    bezel: 26,
    titleSize: 104,
    subtitleSize: 50,
    titleTop: 190,
    iconSize: 150,
    isPad: false
)
let ipad = Device(
    folder: "ipad-13",
    rawFolder: "raw/ipad",
    size: CGSize(width: 2064, height: 2752),
    deviceWidth: 1720,
    screenTop: 760,
    screenCorner: 46,
    bezel: 34,
    titleSize: 128,
    subtitleSize: 60,
    titleTop: 160,
    iconSize: 170,
    isPad: true
)

// MARK: - Drawing helpers (top-left origin via flipped context)

func paragraph(_ align: NSTextAlignment = .center, lineSpacing: CGFloat = 0) -> NSMutableParagraphStyle {
    let p = NSMutableParagraphStyle()
    p.alignment = align
    p.baseWritingDirection = .rightToLeft
    p.lineSpacing = lineSpacing
    return p
}

func drawText(
    _ string: String,
    font: NSFont,
    color: NSColor,
    centerX: CGFloat,
    top: CGFloat,
    width: CGFloat,
    lineSpacing: CGFloat = 0
) -> CGFloat {
    let attrs: [NSAttributedString.Key: Any] = [
        .font: font,
        .foregroundColor: color,
        .paragraphStyle: paragraph(lineSpacing: lineSpacing)
    ]
    let s = NSAttributedString(string: string, attributes: attrs)
    let bounds = s.boundingRect(
        with: CGSize(width: width, height: 2000),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    s.draw(
        with: CGRect(x: centerX - width / 2, y: top, width: width, height: ceil(bounds.height)),
        options: [.usesLineFragmentOrigin, .usesFontLeading]
    )
    return ceil(bounds.height)
}

func diamond(_ ctx: CGContext, center: CGPoint, size: CGFloat, color: NSColor) {
    ctx.saveGState()
    ctx.setFillColor(color.cgColor)
    ctx.move(to: CGPoint(x: center.x, y: center.y - size / 2))
    ctx.addLine(to: CGPoint(x: center.x + size / 2, y: center.y))
    ctx.addLine(to: CGPoint(x: center.x, y: center.y + size / 2))
    ctx.addLine(to: CGPoint(x: center.x - size / 2, y: center.y))
    ctx.closePath()
    ctx.fillPath()
    ctx.restoreGState()
}

/// The three-dot motif of the letter "چ" from the app icon.
func dotsMotif(_ ctx: CGContext, center: CGPoint, size: CGFloat, color: NSColor) {
    let gap = size * 1.08
    diamond(ctx, center: CGPoint(x: center.x - gap / 2, y: center.y - gap / 2), size: size, color: color)
    diamond(ctx, center: CGPoint(x: center.x + gap / 2, y: center.y - gap / 2), size: size, color: color)
    diamond(ctx, center: CGPoint(x: center.x, y: center.y + gap / 2), size: size, color: color)
}

func drawBackground(_ ctx: CGContext, theme: Theme, size: CGSize) {
    let colors: [NSColor] = switch theme {
    case .blue: [skyBlue, royalBlue]
    case .light: [paper, paper2]
    case .navy: [rgb(0x15407F), deepNavy]
    }
    let gradient = CGGradient(
        colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
        colors: colors.map(\.cgColor) as CFArray,
        locations: [0, 1]
    )!
    ctx.drawLinearGradient(gradient, start: .zero, end: CGPoint(x: size.width, y: size.height), options: [])

    // Soft glow behind the device.
    let glowColor: NSColor = theme == .light ? rgb(0x1A6FE0, 0.10) : rgb(0xFFFFFF, 0.12)
    let glow = CGGradient(
        colorsSpace: CGColorSpace(name: CGColorSpace.sRGB),
        colors: [glowColor.cgColor, glowColor.withAlphaComponent(0).cgColor] as CFArray,
        locations: [0, 1]
    )!
    let c = CGPoint(x: size.width / 2, y: size.height * 0.62)
    ctx.drawRadialGradient(glow, startCenter: c, startRadius: 0, endCenter: c, endRadius: size.width * 0.75, options: [])

    // Decorative diamonds.
    let motif: NSColor = theme == .light ? rgb(0x1A6FE0, 0.07) : rgb(0xFFFFFF, 0.08)
    let u = size.width / 1206
    dotsMotif(ctx, center: CGPoint(x: size.width - 120 * u, y: size.height * 0.42), size: 150 * u, color: motif)
    dotsMotif(ctx, center: CGPoint(x: 110 * u, y: size.height * 0.30), size: 90 * u, color: motif)
    diamond(ctx, center: CGPoint(x: 95 * u, y: size.height * 0.80), size: 60 * u, color: motif)
}

func roundedPath(_ rect: CGRect, _ r: CGFloat) -> CGPath {
    CGPath(roundedRect: rect, cornerWidth: r, cornerHeight: r, transform: nil)
}

func loadImage(_ url: URL) -> CGImage? {
    guard let src = CGImageSourceCreateWithURL(url as CFURL, nil) else { return nil }
    return CGImageSourceCreateImageAtIndex(src, 0, nil)
}

/// iPad captures carry an English date in the status bar and the window-resize handle in the corner.
/// Paint both over with the surrounding background colour.
func cleanedPadScreenshot(_ image: CGImage) -> CGImage {
    let w = image.width, h = image.height
    let cs = CGColorSpace(name: CGColorSpace.sRGB)!
    guard let ctx = CGContext(
        data: nil,
        width: w,
        height: h,
        bitsPerComponent: 8,
        bytesPerRow: w * 4,
        space: cs,
        bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
    ) else { return image }
    ctx.draw(image, in: CGRect(x: 0, y: 0, width: w, height: h))
    guard let data = ctx.data?.assumingMemoryBound(to: UInt8.self) else { return image }
    // Context memory is top-down rows.
    func color(atX x: Int, y: Int) -> CGColor {
        let i = (y * w + x) * 4
        return CGColor(
            srgbRed: CGFloat(data[i]) / 255,
            green: CGFloat(data[i + 1]) / 255,
            blue: CGFloat(data[i + 2]) / 255,
            alpha: 1
        )
    }
    let dateFill = color(atX: 380, y: 30)
    let cornerFill = color(atX: w - 200, y: h - 8)
    // CG drawing coordinates are bottom-up.
    ctx.setFillColor(dateFill)
    ctx.fill(CGRect(x: 138, y: h - 70, width: 212, height: 70))
    ctx.setFillColor(cornerFill)
    ctx.fill(CGRect(x: w - 130, y: 0, width: 130, height: 130))
    return ctx.makeImage() ?? image
}

// MARK: - Compose

func compose(_ slide: Slide, index: Int, device: Device, icon: CGImage?) throws {
    let size = device.size
    guard let rep = NSBitmapImageRep(
              bitmapDataPlanes: nil,
              pixelsWide: Int(size.width),
              pixelsHigh: Int(size.height),
              bitsPerSample: 8,
              samplesPerPixel: 4,
              hasAlpha: true,
              isPlanar: false,
              colorSpaceName: .deviceRGB,
              bytesPerRow: 0,
              bitsPerPixel: 0
          ),
          let gctx = NSGraphicsContext(bitmapImageRep: rep) else { return }
    rep.size = size
    NSGraphicsContext.saveGraphicsState()
    let flipped = NSGraphicsContext(cgContext: gctx.cgContext, flipped: true)
    NSGraphicsContext.current = flipped
    let ctx = flipped.cgContext
    ctx.translateBy(x: 0, y: size.height)
    ctx.scaleBy(x: 1, y: -1)

    drawBackground(ctx, theme: slide.theme, size: size)

    let titleColor: NSColor = slide.theme == .light ? deepNavy : .white
    let accentColor: NSColor = slide.theme == .light ? royalBlue : gold
    let subColor: NSColor = slide.theme == .light ? rgb(0x0B2A5B, 0.70) : rgb(0xFFFFFF, 0.85)
    let textWidth = size.width - (device.isPad ? 360 : 140)

    var y = device.titleTop
    if slide.hero, let icon {
        let s = device.iconSize
        let rect = CGRect(x: (size.width - s) / 2, y: y - 40, width: s, height: s)
        ctx.saveGState()
        ctx.setShadow(offset: CGSize(width: 0, height: 10), blur: 30, color: rgb(0x000000, 0.25).cgColor)
        ctx.addPath(roundedPath(rect, s * 0.225))
        ctx.setFillColor(NSColor.white.cgColor)
        ctx.fillPath()
        ctx.restoreGState()
        ctx.saveGState()
        ctx.addPath(roundedPath(rect, s * 0.225))
        ctx.clip()
        // Image drawing in a flipped CTM needs a local flip.
        ctx.translateBy(x: rect.minX, y: rect.maxY)
        ctx.scaleBy(x: 1, y: -1)
        ctx.draw(icon, in: CGRect(origin: .zero, size: rect.size))
        ctx.restoreGState()
        y += s - 10
    }

    let titleFont = NSFont.systemFont(ofSize: device.titleSize, weight: .heavy)
    y += drawText(slide.title1, font: titleFont, color: titleColor, centerX: size.width / 2, top: y, width: textWidth)
    y -= device.titleSize * 0.12
    y += drawText(slide.title2, font: titleFont, color: accentColor, centerX: size.width / 2, top: y, width: textWidth)
    y += device.titleSize * 0.22
    let subFont = NSFont(name: "Vazirmatn-Regular", size: device.subtitleSize)
        ?? NSFont.systemFont(ofSize: device.subtitleSize)
    _ = drawText(slide.subtitle, font: subFont, color: subColor, centerX: size.width / 2, top: y, width: textWidth)

    // Device
    let rawURL = base.appendingPathComponent("\(device.rawFolder)/\(slide.raw).png")
    guard var shot = loadImage(rawURL) else { throw NSError(
        domain: "compose",
        code: 1,
        userInfo: [NSLocalizedDescriptionKey: "missing \(rawURL.path)"]
    ) }
    if device.isPad {
        shot = cleanedPadScreenshot(shot)
    }
    let screenW = device.deviceWidth
    let screenH = screenW * CGFloat(shot.height) / CGFloat(shot.width)
    let screenTop = device.screenTop + (slide.hero ? device.iconSize * 0.55 : 0)
    let screen = CGRect(x: (size.width - screenW) / 2, y: screenTop, width: screenW, height: screenH)
    let b = device.bezel
    let body = screen.insetBy(dx: -b, dy: -b)
    let bodyRadius = device.screenCorner + b

    // Shadow + body
    ctx.saveGState()
    ctx.setShadow(
        offset: CGSize(width: 0, height: 30),
        blur: 90,
        color: rgb(0x000000, slide.theme == .light ? 0.22 : 0.40).cgColor
    )
    ctx.addPath(roundedPath(body, bodyRadius))
    ctx.setFillColor(rgb(0x1C1C1E).cgColor)
    ctx.fillPath()
    ctx.restoreGState()
    // Metallic rim
    ctx.saveGState()
    ctx.addPath(roundedPath(body.insetBy(dx: 3, dy: 3), bodyRadius - 3))
    ctx.setStrokeColor(rgb(0x8E8E93, 0.9).cgColor)
    ctx.setLineWidth(5)
    ctx.strokePath()
    ctx.restoreGState()

    // Screen
    ctx.saveGState()
    ctx.addPath(roundedPath(screen, device.screenCorner))
    ctx.clip()
    ctx.translateBy(x: screen.minX, y: screen.maxY)
    ctx.scaleBy(x: 1, y: -1)
    ctx.interpolationQuality = .high
    ctx.draw(shot, in: CGRect(origin: .zero, size: screen.size))
    ctx.restoreGState()

    NSGraphicsContext.restoreGraphicsState()

    let outDir = base.appendingPathComponent(device.folder)
    try FileManager.default.createDirectory(at: outDir, withIntermediateDirectories: true)
    let name = String(format: "%02d-%@.png", index + 1, String(slide.raw.dropFirst(3)))
    // Flatten to RGB without alpha (App Store rejects images with transparency).
    guard let cg = rep.cgImage,
          let flat = CGContext(
              data: nil,
              width: cg.width,
              height: cg.height,
              bitsPerComponent: 8,
              bytesPerRow: 0,
              space: CGColorSpace(name: CGColorSpace.sRGB)!,
              bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue
          ) else { return }
    flat.draw(cg, in: CGRect(x: 0, y: 0, width: cg.width, height: cg.height))
    guard let out = flat.makeImage() else { return }
    let dest = NSBitmapImageRep(cgImage: out)
    guard let png = dest.representation(using: .png, properties: [:]) else { return }
    try png.write(to: outDir.appendingPathComponent(name))
    print("wrote \(device.folder)/\(name)")
}

let icon = loadImage(root.appendingPathComponent("Chakame/Assets.xcassets/AppIcon.appiconset/AppIcon@1024.png"))
for device in [iphone, ipad] {
    for (i, slide) in slides.enumerated() {
        do { try compose(slide, index: i, device: device, icon: icon) } catch { print("error: \(error)") }
    }
}
