//
//  BusinessCard.swift
//  BusinessCardKit
//

import UIKit

/// All data shown on a business card. The host app builds one of these
/// from its own user model and injects it — the kit has no knowledge of
/// any networking, caching, or user session.
///
/// Every field is optional (except `name`); a field renders only when the
/// active nib connects an outlet for it, and is skipped in the vCard when
/// empty — so a card uses exactly the fields it needs.
public struct BusinessCard {

    // MARK: Identity

    public var name: String
    /// Arabic rendering of the name, shown above the Latin name. Optional —
    /// the line collapses when empty.
    public var nameArabic: String?
    /// Qualifications shown after the name (e.g. "PhD, PMP").
    public var credentials: String?
    /// Displayed only — not part of the shared vCard.
    public var pronouns: String?
    /// Headshot. Displayed as-is (not template-tinted) and excluded from the
    /// QR vCard, whose capacity is far too small for image data.
    public var photo: UIImage?

    // MARK: Role

    public var designation: String?
    /// Arabic rendering of the designation, shown above the Latin one.
    public var designationArabic: String?
    public var department: String?
    public var companyName: String?
    public var companyNameArabic: String?
    /// Company tagline / slogan.
    public var companyTagline: String?

    // MARK: Contact

    public var mobileNumber: String?
    public var secondaryMobileNumber: String?
    /// WhatsApp contact — number or wa.me link, whichever the host prefers.
    public var whatsappNumber: String?
    public var landlineNumber: String?
    public var faxNumber: String?
    public var email: String?
    public var secondaryEmail: String?
    public var website: String?

    // MARK: Address

    public var addressLines: [String]

    // MARK: Social

    /// Profile URLs or handles, passed through to the vCard as social
    /// profiles (X-SOCIALPROFILE) and rendered verbatim on the card.
    public var linkedIn: String?
    public var instagram: String?
    public var twitter: String?

    // MARK: Regulatory

    /// Professional license / registration (e.g. a RERA broker number),
    /// carried in the vCard NOTE field.
    public var licenseNumber: String?

    // MARK: Branding

    public var logo: UIImage?

    public init(name: String,
                nameArabic: String? = nil,
                credentials: String? = nil,
                pronouns: String? = nil,
                photo: UIImage? = nil,
                designation: String? = nil,
                designationArabic: String? = nil,
                department: String? = nil,
                companyName: String? = nil,
                companyNameArabic: String? = nil,
                companyTagline: String? = nil,
                addressLines: [String] = [],
                mobileNumber: String? = nil,
                secondaryMobileNumber: String? = nil,
                whatsappNumber: String? = nil,
                landlineNumber: String? = nil,
                faxNumber: String? = nil,
                email: String? = nil,
                secondaryEmail: String? = nil,
                website: String? = nil,
                linkedIn: String? = nil,
                instagram: String? = nil,
                twitter: String? = nil,
                licenseNumber: String? = nil,
                logo: UIImage? = nil) {
        self.name = name
        self.nameArabic = nameArabic
        self.credentials = credentials
        self.pronouns = pronouns
        self.photo = photo
        self.designation = designation
        self.designationArabic = designationArabic
        self.department = department
        self.companyName = companyName
        self.companyNameArabic = companyNameArabic
        self.companyTagline = companyTagline
        self.addressLines = addressLines
        self.mobileNumber = mobileNumber
        self.secondaryMobileNumber = secondaryMobileNumber
        self.whatsappNumber = whatsappNumber
        self.landlineNumber = landlineNumber
        self.faxNumber = faxNumber
        self.email = email
        self.secondaryEmail = secondaryEmail
        self.website = website
        self.linkedIn = linkedIn
        self.instagram = instagram
        self.twitter = twitter
        self.licenseNumber = licenseNumber
        self.logo = logo
    }
}

public extension BusinessCard {

    /// Fully populated sample data, rendered by `BusinessCardViewController`
    /// whenever demo mode is on so the finished layout can be reviewed before
    /// real data exists. Carries no logo or photo of its own — demo mode
    /// borrows the logo of the first injected card, keeping the kit free of
    /// any host-app asset dependency.
    static let demo = BusinessCard(
        name: "Amira Albeshr",
        nameArabic: "أميرة البشر",
        credentials: "MBA",
        pronouns: "she/her",
        designation: "Customer Experience Ambassador",
        designationArabic: "سفير خدمة العملاء",
        department: "Customer Experience",
        companyName: "Binghatti Corporate Office",
        companyNameArabic: "بن غاطي",
        companyTagline: "Where Innovation Meets Design",
        addressLines: ["6th Floor, H Hotel Office Tower",
                       "Dubai, UAE  |  +971 4 355 5888"],
        mobileNumber: "+971 56 967 3271",
        secondaryMobileNumber: "+971 50 123 4567",
        whatsappNumber: "+971 56 967 3271",
        landlineNumber: "+971 4 355 5888",
        faxNumber: "+971 4 355 5889",
        email: "amira.albeshr@binghatti.com",
        secondaryEmail: "cx@binghatti.com",
        website: "www.binghatti.com",
        linkedIn: "linkedin.com/company/binghatti",
        instagram: "@binghatti",
        twitter: "@binghatti",
        licenseNumber: "RERA 12345"
    )
}
