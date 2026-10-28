//
//  QRCodeRenderer.swift
//  BusinessCardKit
//

import UIKit
import CoreImage.CIFilterBuiltins

enum QRCodeRenderer {

    /// Shared rendering context — creating a `CIContext` is expensive, and
    /// one context can serve every render.
    private static let context = CIContext()

    /// Raw QR code (black modules on white) for the given string.
    static func image(for string: String, scale: CGFloat = 8) -> UIImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage?
            .transformed(by: CGAffineTransform(scaleX: scale, y: scale)) else { return nil }

        // Render through CIContext so the result is backed by a CGImage,
        // which UIActivityViewController and UIImageView both need.
        guard let cgImage = context.createCGImage(output, from: output.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    /// A business-card-sized image (same aspect, background and corner radius
    /// as the card) with the QR centred on a white tile so it stays scannable
    /// on the dark stock. Used for both the on-screen viewer and sharing.
    static func cardImage(for string: String, appearance: BusinessCardAppearance) -> UIImage? {
        guard let qr = image(for: string) else { return nil }

        let renderHeight: CGFloat = 720
        let tileHeightRatio: CGFloat = 0.72   // white tile side vs card height
        let qrInsetRatio: CGFloat = 0.08      // QR inset vs tile side

        let width = (renderHeight * appearance.cardAspectRatio).rounded()
        let size = CGSize(width: width, height: renderHeight)

        return UIGraphicsImageRenderer(size: size).image { ctx in
            let cardRect = CGRect(origin: .zero, size: size)

            // Card background, with the corner radius scaled up from its
            // on-screen reference size to this render size.
            let corner = appearance.cornerRadius / BusinessCardAppearance.referenceCardHeight * renderHeight
            let cardPath = UIBezierPath(roundedRect: cardRect, cornerRadius: corner)
            appearance.cardBackgroundColor.setFill()
            cardPath.fill()

            // Centred white QR tile.
            let tileSide = renderHeight * tileHeightRatio
            let tileRect = CGRect(x: (width - tileSide) / 2,
                                  y: (renderHeight - tileSide) / 2,
                                  width: tileSide, height: tileSide)
            let tilePath = UIBezierPath(roundedRect: tileRect, cornerRadius: corner * 0.8)
            UIColor.white.setFill()
            tilePath.fill()

            // QR, crisp (no smoothing), inset inside the tile.
            let qrRect = tileRect.insetBy(dx: tileSide * qrInsetRatio, dy: tileSide * qrInsetRatio)
            ctx.cgContext.interpolationQuality = .none
            qr.draw(in: qrRect)
        }
    }
}
