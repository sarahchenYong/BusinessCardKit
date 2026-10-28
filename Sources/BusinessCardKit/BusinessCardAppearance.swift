//
//  BusinessCardAppearance.swift
//  BusinessCardKit
//

import UIKit

/// Visual customization injected by the host app. Defaults reproduce the
/// printed Binghatti corporate card: matte-black stock, white foil text,
/// a serif name and Rubik detail type.
public struct BusinessCardAppearance {

    public var textColor: UIColor
    public var cardBackgroundColor: UIColor
    /// Corner radius in points, specified against an on-screen card of
    /// roughly `referenceCardHeight` points.
    public var cornerRadius: CGFloat
    /// Serif face used for the Latin name (matches the card's engraved name).
    public var nameFont: UIFont
    public var nameArabicFont: UIFont
    /// Bold sans face used for the Latin designation.
    public var designationFont: UIFont
    public var designationArabicFont: UIFont
    /// Face used for every contact / corporate-office detail line.
    public var detailFont: UIFont
    /// Width / height. 1.6 mirrors a standard business card.
    public var cardAspectRatio: CGFloat

    /// When true the back of the card is shown in addition to the front.
    /// Defaults to false (front only).
    public var showsBackSide: Bool

    // MARK: Porting hooks — swap the whole layout without touching the kit.

    /// Nib used for the front face. Point at your own nib (with the same
    /// outlet names on `BusinessCardView`) to give a new client a bespoke
    /// front layout. Defaults to the kit's bundled `BusinessCardFrontView`.
    public var frontNibName: String
    /// Nib used for the back face (outlets on `BusinessCardBackView`).
    /// Defaults to the kit's bundled `BusinessCardBackView`.
    public var backNibName: String
    /// Bundle the nibs are loaded from. `nil` uses the kit's own resource
    /// bundle; set to `.main` (or a client bundle) when the nib lives in the
    /// host app so designers can edit it there.
    public var nibBundle: Bundle?

    public init(textColor: UIColor = .white,
                cardBackgroundColor: UIColor = UIColor(red: 17/255, green: 17/255, blue: 17/255, alpha: 1),
                cornerRadius: CGFloat = 12,
                nameFont: UIFont = BusinessCardFonts.serif(21),
                nameArabicFont: UIFont = .systemFont(ofSize: 13),
                designationFont: UIFont = BusinessCardFonts.rubikMedium(12.5),
                designationArabicFont: UIFont = .systemFont(ofSize: 11.5),
                detailFont: UIFont = BusinessCardFonts.rubikMedium(11),
                cardAspectRatio: CGFloat = 1.6,
                showsBackSide: Bool = false,
                frontNibName: String = "BusinessCardFrontView",
                backNibName: String = "BusinessCardBackView",
                nibBundle: Bundle? = nil) {
        self.textColor = textColor
        self.cardBackgroundColor = cardBackgroundColor
        self.cornerRadius = cornerRadius
        self.nameFont = nameFont
        self.nameArabicFont = nameArabicFont
        self.designationFont = designationFont
        self.designationArabicFont = designationArabicFont
        self.detailFont = detailFont
        self.cardAspectRatio = cardAspectRatio
        self.showsBackSide = showsBackSide
        self.frontNibName = frontNibName
        self.backNibName = backNibName
        self.nibBundle = nibBundle
    }

    /// On-screen card height (points) that `cornerRadius` is specified
    /// against; off-screen renders scale the radius from this reference.
    static let referenceCardHeight: CGFloat = 220

    /// Bundle the card nibs are resolved from.
    var resolvedNibBundle: Bundle { nibBundle ?? .module }

    /// The Binghatti corporate card look (also the default).
    public static let binghatti = BusinessCardAppearance()
    public static let `default` = BusinessCardAppearance()
}

/// Font resolution for the card, with system fallbacks so the kit renders
/// correctly even if a bundled face fails to register.
public enum BusinessCardFonts {

    public static func rubikMedium(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Medium", size: size) ?? .systemFont(ofSize: size, weight: .medium)
    }

    public static func rubikRegular(_ size: CGFloat) -> UIFont {
        UIFont(name: "Rubik-Regular", size: size) ?? .systemFont(ofSize: size, weight: .regular)
    }

    public static func serif(_ size: CGFloat) -> UIFont {
        if let times = UIFont(name: "TimesNewRomanPSMT", size: size) { return times }
        if let descriptor = UIFont.systemFont(ofSize: size).fontDescriptor.withDesign(.serif) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return UIFont(name: "Georgia", size: size) ?? .systemFont(ofSize: size)
    }
}
