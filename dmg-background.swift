import Cocoa
// usage: dmg-background <out.png>  (540x360 pt, rendered @2x)
let w = 540, h = 360
let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: w*2, pixelsHigh: h*2, bitsPerSample: 8,
    samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0)!
rep.size = NSSize(width: w, height: h)
NSGraphicsContext.saveGraphicsState()
NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
NSGradient(colors: [NSColor(white: 0.98, alpha: 1), NSColor(white: 0.90, alpha: 1)])!
    .draw(in: NSRect(x: 0, y: 0, width: w, height: h), angle: -90)
let para = NSMutableParagraphStyle(); para.alignment = .center
let title = NSAttributedString(string: "Drag SideNav to the Applications folder", attributes: [
    .font: NSFont.systemFont(ofSize: 17, weight: .medium), .foregroundColor: NSColor(white: 0.25, alpha: 1), .paragraphStyle: para])
title.draw(in: NSRect(x: 0, y: h - 70, width: w, height: 28))
// arrow between the two icons (icon centres at x=140 and x=400, y=175 from top)
let y = CGFloat(h - 175)
let arrow = NSBezierPath()
arrow.lineWidth = 5; arrow.lineCapStyle = .round; arrow.lineJoinStyle = .round
arrow.move(to: NSPoint(x: 215, y: y)); arrow.line(to: NSPoint(x: 325, y: y))
arrow.move(to: NSPoint(x: 305, y: y + 18)); arrow.line(to: NSPoint(x: 325, y: y)); arrow.line(to: NSPoint(x: 305, y: y - 18))
NSColor(white: 0.55, alpha: 1).setStroke(); arrow.stroke()
NSGraphicsContext.restoreGraphicsState()
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
