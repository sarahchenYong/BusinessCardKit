//
//  BusinessCardView.swift
//  BusinessCardKit
//

import UIKit

/// Front of the card. The bundled layout (`BusinessCardFrontView.xib`) puts
/// the logo top-left, name top-right, designation mid-right, contact
/// bottom-right and corporate office bottom-left. Every element is an
/// outlet, so a new client only edits the nib — outlets left unconnected
/// simply don't render.
public final class BusinessCardView: BusinessCardFaceView {

    // MARK: Identity
    /// Headshot; shown as-is (not template-tinted), hidden when the card
    /// carries no photo.
    @IBOutlet weak var photoImageView: UIImageView?
    @IBOutlet weak var nameArabicLabel: UILabel?
    @IBOutlet weak var nameLabel: UILabel?
    @IBOutlet weak var credentialsLabel: UILabel?
    @IBOutlet weak var pronounsLabel: UILabel?

    // MARK: Role
    @IBOutlet weak var designationArabicLabel: UILabel?
    @IBOutlet weak var designationLabel: UILabel?
    @IBOutlet weak var departmentLabel: UILabel?
    @IBOutlet weak var companyArabicLabel: UILabel?
    @IBOutlet weak var companyLabel: UILabel?
    @IBOutlet weak var taglineLabel: UILabel?

    // MARK: Contact
    @IBOutlet weak var mobileLabel: UILabel?
    @IBOutlet weak var secondaryMobileLabel: UILabel?
    @IBOutlet weak var whatsappLabel: UILabel?
    @IBOutlet weak var landlineLabel: UILabel?
    @IBOutlet weak var faxLabel: UILabel?
    @IBOutlet weak var emailLabel: UILabel?
    @IBOutlet weak var secondaryEmailLabel: UILabel?
    @IBOutlet weak var websiteLabel: UILabel?

    // MARK: Address
    /// Vertical stack holding the office block; address lines are injected
    /// here at runtime (one label each) so any number of lines is supported.
    @IBOutlet weak var officeStackView: UIStackView?
    /// Optional single multiline address label — used only if a client's nib
    /// has no `officeStackView`.
    @IBOutlet weak var addressLabel: UILabel?

    // MARK: Social
    @IBOutlet weak var linkedInLabel: UILabel?
    @IBOutlet weak var instagramLabel: UILabel?
    @IBOutlet weak var twitterLabel: UILabel?

    // MARK: Regulatory
    @IBOutlet weak var licenseLabel: UILabel?

    public convenience init(card: BusinessCard, appearance: BusinessCardAppearance = .default) {
        self.init(card: card, appearance: appearance, nibName: appearance.frontNibName)
    }

    public override func configure(card: BusinessCard, appearance: BusinessCardAppearance) {
        let color = appearance.textColor

        // Identity
        photoImageView?.image = card.photo
        photoImageView?.isHidden = card.photo == nil
        apply(card.nameArabic, to: nameArabicLabel, font: appearance.nameArabicFont, color: color)
        apply(card.name, to: nameLabel, font: appearance.nameFont, color: color)
        apply(card.credentials, to: credentialsLabel, font: appearance.detailFont, color: color)
        apply(card.pronouns, to: pronounsLabel, font: appearance.detailFont, color: color)

        // Role
        apply(card.designationArabic, to: designationArabicLabel, font: appearance.designationArabicFont, color: color)
        apply(card.designation, to: designationLabel, font: appearance.designationFont, color: color)
        apply(card.department, to: departmentLabel, font: appearance.detailFont, color: color)
        apply(card.companyNameArabic, to: companyArabicLabel, font: appearance.detailFont, color: color)
        apply(card.companyName, to: companyLabel, font: appearance.detailFont, color: color)
        apply(card.companyTagline, to: taglineLabel, font: appearance.detailFont, color: color)

        // Contact
        apply(card.mobileNumber, to: mobileLabel, font: appearance.detailFont, color: color)
        apply(card.secondaryMobileNumber, to: secondaryMobileLabel, font: appearance.detailFont, color: color)
        apply(card.whatsappNumber, to: whatsappLabel, font: appearance.detailFont, color: color)
        apply(card.landlineNumber, to: landlineLabel, font: appearance.detailFont, color: color)
        apply(card.faxNumber, to: faxLabel, font: appearance.detailFont, color: color)
        apply(card.email, to: emailLabel, font: appearance.detailFont, color: color)
        apply(card.secondaryEmail, to: secondaryEmailLabel, font: appearance.detailFont, color: color)
        apply(card.website, to: websiteLabel, font: appearance.detailFont, color: color)

        // Address
        let addressLines = card.addressLines.filter { !$0.isEmpty }
        if let officeStackView {
            // One single-line label per address line (matches the printed card
            // and supports any number of lines).
            for line in addressLines {
                let label = UILabel()
                label.numberOfLines = 1
                label.textAlignment = .left
                apply(line, to: label, font: appearance.detailFont, color: color)
                officeStackView.addArrangedSubview(label)
            }
        } else {
            apply(addressLines.joined(separator: "\n"), to: addressLabel,
                  font: appearance.detailFont, color: color, autoshrink: false)
        }

        // Social
        apply(card.linkedIn, to: linkedInLabel, font: appearance.detailFont, color: color)
        apply(card.instagram, to: instagramLabel, font: appearance.detailFont, color: color)
        apply(card.twitter, to: twitterLabel, font: appearance.detailFont, color: color)

        // Regulatory
        apply(card.licenseNumber, to: licenseLabel, font: appearance.detailFont, color: color)
    }
}

/// Back of the card. The bundled layout (`BusinessCardBackView.xib`) is the
/// logo centred on the card stock. Clients can point `backNibName` at their
/// own nib (with a `logoImageView` outlet). The logo is bound by the base
/// class, so there is nothing left to configure.
public final class BusinessCardBackView: BusinessCardFaceView {

    public convenience init(card: BusinessCard, appearance: BusinessCardAppearance = .default) {
        self.init(card: card, appearance: appearance, nibName: appearance.backNibName)
    }
}
