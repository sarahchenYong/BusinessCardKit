//
//  QRCodeViewController.swift
//  BusinessCardKit
//

import UIKit

/// Minimal full-screen QR display, dismissed by tapping anywhere. The QR card
/// image is centred on screen at its own (business-card) aspect ratio.
final class QRCodeViewController: UIViewController {

    private enum Layout {
        static let backgroundAlpha: CGFloat = 0.92
        static let widthMultiplier: CGFloat = 0.88
    }

    private let image: UIImage

    init(image: UIImage) {
        self.image = image
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
        modalTransitionStyle = .crossDissolve
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) is not supported — use init(image:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(Layout.backgroundAlpha)

        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        // Size to the image's own aspect ratio (the card shape), centred.
        let aspect = image.size.height / max(image.size.width, 1)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: Layout.widthMultiplier),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspect)
        ])

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(close)))
    }

    @objc private func close() {
        dismiss(animated: true)
    }
}
