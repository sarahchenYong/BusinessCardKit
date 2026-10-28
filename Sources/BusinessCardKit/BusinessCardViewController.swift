//
//  BusinessCardViewController.swift
//  BusinessCardKit
//

import UIKit

/// Presents one or more business cards in a self-sizing bottom sheet.
/// Long-pressing a card offers share-card, share-QR and view-QR actions.
/// When `appearance.showsBackSide` is true each card's back face is shown
/// beneath its front.
///
///     var card = BusinessCard(name: "Jane Doe")
///     card.email = "jane@example.com"
///     let controller = BusinessCardViewController(cards: [card])
///     controller.presentCard(from: self)
public final class BusinessCardViewController: UIViewController {

    /// Hooks fired on user actions so the host can plug in analytics (or
    /// anything else) using its own event vocabulary — the kit defines none.
    public var onShareCard: (() -> Void)?
    public var onShareQRCode: (() -> Void)?
    public var onViewQRCode: (() -> Void)?

    /// Hint shown above the cards. Replace for localization.
    public var shareHintText = "Long press on card to share"

    public var shareActionTitle = "Share Card"
    public var shareQRActionTitle = "Share QR Code"
    public var viewQRActionTitle = "View QR Code"

    /// A rendered face paired with the card it came from, so the context
    /// menu and logo updates can act on it.
    private struct Face {
        let view: BusinessCardFaceView
        var card: BusinessCard
    }

    private enum Layout {
        static let padding: CGFloat = 20
        static let hintSpacing: CGFloat = 12
        static let interCardSpacing: CGFloat = 16
        static let maxCardWidth: CGFloat = 420
    }

    private let cards: [BusinessCard]
    private let appearance: BusinessCardAppearance
    private var faces: [Face] = []

    private var facesPerCard: Int { appearance.showsBackSide ? 2 : 1 }

    /// - Parameter showDemoData: when true, ignores `cards` and renders
    ///   `BusinessCard.demo` instead — every field populated with sample
    ///   values, so the full layout can be reviewed before real data exists.
    ///   The demo card borrows the first injected card's logo.
    public init(cards: [BusinessCard],
                appearance: BusinessCardAppearance = .default,
                showDemoData: Bool = false) {
        var resolvedCards = cards
        if showDemoData {
            var demo = BusinessCard.demo
            demo.logo = cards.first?.logo
            resolvedCards = [demo]
        }
        precondition(!resolvedCards.isEmpty, "BusinessCardViewController needs at least one card")
        self.cards = resolvedCards
        self.appearance = appearance
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported — use init(cards:appearance:)")
    }

    /// Replaces the logo on every rendered face (cross-fading), so callers
    /// can present the card immediately with a placeholder logo and swap in
    /// a remote one once it finishes downloading.
    public func updateLogo(_ logo: UIImage?) {
        loadViewIfNeeded()
        for index in faces.indices {
            faces[index].card.logo = logo
            faces[index].view.updateLogo(logo)
        }
    }

    // MARK: - Presentation

    /// Presents as a bottom sheet hugging the content height
    /// (cards + hint + padding). Form sheet of the same size on iPad.
    public func presentCard(from presenter: UIViewController) {
        if UIDevice.current.userInterfaceIdiom == .pad {
            modalPresentationStyle = .formSheet
            let width = Layout.maxCardWidth + 2 * Layout.padding
            preferredContentSize = CGSize(width: width, height: contentHeight(forContainerWidth: width))
        } else {
            modalPresentationStyle = .pageSheet
            if let sheet = sheetPresentationController {
                let containerWidth = presenter.view.bounds.width
                sheet.detents = [.custom { [weak self] context in
                    guard let self else { return context.maximumDetentValue }
                    return min(self.contentHeight(forContainerWidth: containerWidth),
                               context.maximumDetentValue)
                }]
                sheet.prefersGrabberVisible = true
                sheet.preferredCornerRadius = 16
            }
        }
        presenter.present(self, animated: true)
    }

    private func contentHeight(forContainerWidth containerWidth: CGFloat) -> CGFloat {
        let cardWidth = min(containerWidth - 2 * Layout.padding, Layout.maxCardWidth)
        let cardHeight = cardWidth / appearance.cardAspectRatio
        let faceCount = cards.count * facesPerCard
        let cardsHeight = cardHeight * CGFloat(faceCount) + Layout.interCardSpacing * CGFloat(faceCount - 1)
        let hintHeight = shareHintText.isEmpty ? -Layout.hintSpacing : UIFont.preferredFont(forTextStyle: .footnote).lineHeight
        return Layout.padding + hintHeight + Layout.hintSpacing + cardsHeight + Layout.padding
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        let hintLabel = UILabel()
        hintLabel.text = shareHintText
        hintLabel.font = .preferredFont(forTextStyle: .footnote)
        hintLabel.textColor = .secondaryLabel
        hintLabel.textAlignment = .center
        hintLabel.isHidden = shareHintText.isEmpty

        faces = cards.flatMap { card -> [Face] in
            var built = [Face(view: BusinessCardView(card: card, appearance: appearance), card: card)]
            if appearance.showsBackSide {
                built.append(Face(view: BusinessCardBackView(card: card, appearance: appearance), card: card))
            }
            return built
        }
        for face in faces {
            face.view.addInteraction(UIContextMenuInteraction(delegate: self))
        }

        let cardsStack = UIStackView(arrangedSubviews: faces.map { $0.view })
        cardsStack.axis = .vertical
        cardsStack.spacing = Layout.interCardSpacing

        let content = UIStackView(arrangedSubviews: [hintLabel, cardsStack])
        content.axis = .vertical
        content.spacing = Layout.hintSpacing
        content.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(content)

        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.padding),
            content.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            content.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: Layout.padding),
            cardsStack.widthAnchor.constraint(lessThanOrEqualToConstant: Layout.maxCardWidth),
            cardsStack.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -2 * Layout.padding).withPriority(.defaultHigh)
        ])
    }

    // MARK: - Actions

    private func share(_ image: UIImage, from sourceView: UIView) {
        let activity = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if let popover = activity.popoverPresentationController {
            popover.sourceView = sourceView
            popover.sourceRect = sourceView.bounds
        }
        present(activity, animated: true)
    }

    private func qrCardImage(for card: BusinessCard) -> UIImage? {
        QRCodeRenderer.cardImage(for: VCardBuilder.vCard(for: card), appearance: appearance)
    }

    private func showQRCode(for card: BusinessCard) {
        guard let image = qrCardImage(for: card) else { return }
        onViewQRCode?()
        present(QRCodeViewController(image: image), animated: true)
    }
}

// MARK: - Context menu

extension BusinessCardViewController: UIContextMenuInteractionDelegate {

    public func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                       configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        guard let faceView = interaction.view as? BusinessCardFaceView,
              let face = faces.first(where: { $0.view === faceView }) else { return nil }
        let card = face.card

        return UIContextMenuConfiguration(actionProvider: { [weak self] _ in
            guard let self else { return nil }

            let shareCard = UIAction(title: self.shareActionTitle,
                                     image: UIImage(systemName: "square.and.arrow.up")) { [weak self] _ in
                self?.onShareCard?()
                self?.share(faceView.asImage(), from: faceView)
            }

            let shareQR = UIAction(title: self.shareQRActionTitle,
                                   image: UIImage(systemName: "qrcode")) { [weak self] _ in
                guard let self, let qrImage = self.qrCardImage(for: card) else { return }
                self.onShareQRCode?()
                self.share(qrImage, from: faceView)
            }

            let viewQR = UIAction(title: self.viewQRActionTitle,
                                  image: UIImage(systemName: "qrcode.viewfinder")) { [weak self] _ in
                self?.showQRCode(for: card)
            }

            return UIMenu(children: [shareCard, shareQR, viewQR])
        })
    }
}

extension NSLayoutConstraint {
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
}
