//
//  BusinessCardFaceView.swift
//  BusinessCardKit
//

import UIKit

/// A rendered card face that can be snapshotted for sharing.
public protocol BusinessCardFace: UIView {
    func asImage() -> UIImage
}

/// Common behaviour for both card faces: nib loading, container styling,
/// logo binding and snapshotting. Subclasses load a nib (whose File's Owner
/// is the subclass), and implement `configure(card:appearance:)` to bind
/// their remaining outlets — the logo is handled here.
open class BusinessCardFaceView: UIView, BusinessCardFace {

    /// Top-level view of the nib; added as a pinned subview.
    @IBOutlet public var contentView: UIView!

    /// Logo outlet shared by every face (bundled or client-provided).
    /// Rendered as a template image tinted with the appearance text color,
    /// and hidden while the card has no logo.
    @IBOutlet weak var logoImageView: UIImageView?

    public init(card: BusinessCard, appearance: BusinessCardAppearance, nibName: String) {
        super.init(frame: .zero)
        loadContent(nibName: nibName, appearance: appearance)
        styleContainer(appearance)
        bindLogo(card.logo, appearance: appearance)
        configure(card: card, appearance: appearance)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported — use init(card:appearance:)")
    }

    /// Bind the card's data onto the nib's outlets. Override in subclasses.
    /// The logo outlet is already bound by the base class.
    open func configure(card: BusinessCard, appearance: BusinessCardAppearance) {}

    /// Swap the rendered logo in place with a cross-fade, so callers can
    /// present the card immediately with a placeholder and update it once a
    /// remote logo finishes downloading.
    open func updateLogo(_ logo: UIImage?) {
        guard let logoImageView else { return }
        UIView.transition(with: logoImageView, duration: 0.3, options: .transitionCrossDissolve) {
            self.setLogoImage(logo)
        }
    }

    /// Snapshot of just the card content (no wrapper shadow), used for sharing.
    public func asImage() -> UIImage {
        let target = contentView ?? self
        return UIGraphicsImageRenderer(bounds: target.bounds).image { context in
            target.layer.render(in: context.cgContext)
        }
    }

    // MARK: - Logo

    private func bindLogo(_ logo: UIImage?, appearance: BusinessCardAppearance) {
        logoImageView?.tintColor = appearance.textColor
        setLogoImage(logo)
    }

    private func setLogoImage(_ logo: UIImage?) {
        logoImageView?.image = logo?.withRenderingMode(.alwaysTemplate)
        logoImageView?.isHidden = logo == nil
    }

    // MARK: - Nib loading

    private func loadContent(nibName: String, appearance: BusinessCardAppearance) {
        let nib = UINib(nibName: nibName, bundle: appearance.resolvedNibBundle)
        guard let loaded = nib.instantiate(withOwner: self, options: nil).first as? UIView else {
            fatalError("Nib \"\(nibName)\" did not contain a top-level UIView")
        }
        if contentView == nil { contentView = loaded }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthAnchor.constraint(equalTo: heightAnchor, multiplier: appearance.cardAspectRatio)
        ])
    }

    private func styleContainer(_ appearance: BusinessCardAppearance) {
        backgroundColor = .clear
        contentView.backgroundColor = appearance.cardBackgroundColor
        contentView.layer.cornerRadius = appearance.cornerRadius
        contentView.layer.masksToBounds = true
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
    }

    // MARK: - Outlet styling helpers

    /// Applies text, font and colour to an optional label, hiding it when the
    /// text is empty so the surrounding stack view collapses. Text alignment
    /// is left to the nib so client layouts stay in control.
    func apply(_ text: String?, to label: UILabel?, font: UIFont, color: UIColor, autoshrink: Bool = true) {
        guard let label else { return }
        let value = text ?? ""
        label.text = value
        label.font = font
        label.textColor = color
        label.isHidden = value.isEmpty
        if autoshrink && label.numberOfLines == 1 {
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.6
        }
    }
}
