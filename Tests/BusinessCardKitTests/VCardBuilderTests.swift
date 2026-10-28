import XCTest
@testable import BusinessCardKit

final class VCardBuilderTests: XCTestCase {

    func testFullCard() {
        let card = BusinessCard(name: "Jane Doe",
                                designation: "Engineer",
                                companyName: "Acme",
                                addressLines: ["Line 1", "Line 2"],
                                mobileNumber: "+971500000000",
                                landlineNumber: "+97140000000",
                                email: "jane@acme.com",
                                website: "www.acme.com")

        let vCard = VCardBuilder.vCard(for: card)

        XCTAssertTrue(vCard.hasPrefix("BEGIN:VCARD\r\nVERSION:3.0"))
        XCTAssertTrue(vCard.hasSuffix("END:VCARD"))
        XCTAssertTrue(vCard.contains("FN:Jane Doe"))
        XCTAssertTrue(vCard.contains("N:Jane Doe;;;;"))
        XCTAssertTrue(vCard.contains("TITLE:Engineer"))
        XCTAssertTrue(vCard.contains("ORG:Acme"))
        XCTAssertTrue(vCard.contains("TEL;TYPE=CELL:+971500000000"))
        XCTAssertTrue(vCard.contains("TEL;TYPE=WORK:+97140000000"))
        XCTAssertTrue(vCard.contains("EMAIL:jane@acme.com"))
        XCTAssertTrue(vCard.contains("URL:www.acme.com"))
        XCTAssertTrue(vCard.contains("ADR;TYPE=WORK:;;Line 1;Line 2"))
    }

    func testEmptyFieldsAreOmitted() {
        let vCard = VCardBuilder.vCard(for: BusinessCard(name: "Jane Doe"))

        XCTAssertFalse(vCard.contains("TITLE"))
        XCTAssertFalse(vCard.contains("ORG"))
        XCTAssertFalse(vCard.contains("TEL"))
        XCTAssertFalse(vCard.contains("EMAIL"))
        XCTAssertFalse(vCard.contains("URL"))
        XCTAssertFalse(vCard.contains("ADR"))
        XCTAssertFalse(vCard.contains("X-SOCIALPROFILE"))
        XCTAssertFalse(vCard.contains("NOTE"))
    }

    func testExtendedFields() {
        let card = BusinessCard(name: "Jane Doe",
                                credentials: "PhD",
                                pronouns: "she/her",
                                department: "R&D",
                                companyName: "Acme",
                                companyTagline: "Making things",
                                secondaryMobileNumber: "+971501111111",
                                whatsappNumber: "+971502222222",
                                faxNumber: "+97143333333",
                                secondaryEmail: "team@acme.com",
                                linkedIn: "linkedin.com/in/janedoe",
                                instagram: "@janedoe",
                                twitter: "@janedoe",
                                licenseNumber: "RERA 98765")

        let vCard = VCardBuilder.vCard(for: card)

        XCTAssertTrue(vCard.contains("N:Jane Doe;;;;PhD"), "Credentials belong in the N suffix slot")
        XCTAssertTrue(vCard.contains("ORG:Acme;R&D"), "Department rides along as an ORG unit")
        XCTAssertTrue(vCard.contains("TEL;TYPE=CELL:+971501111111"))
        XCTAssertTrue(vCard.contains("TEL;TYPE=FAX:+97143333333"))
        XCTAssertTrue(vCard.contains("EMAIL;TYPE=WORK:team@acme.com"))
        XCTAssertTrue(vCard.contains("X-SOCIALPROFILE;TYPE=linkedin:linkedin.com/in/janedoe"))
        XCTAssertTrue(vCard.contains("X-SOCIALPROFILE;TYPE=instagram:@janedoe"))
        XCTAssertTrue(vCard.contains("X-SOCIALPROFILE;TYPE=twitter:@janedoe"))
        XCTAssertTrue(vCard.contains("X-SOCIALPROFILE;TYPE=whatsapp:+971502222222"))
        XCTAssertTrue(vCard.contains("NOTE:Making things\\nLicense: RERA 98765"))
        XCTAssertFalse(vCard.contains("she/her"), "Pronouns are display-only")
    }

    func testReservedCharactersAreEscaped() {
        let card = BusinessCard(name: "Doe; Jane",
                                designation: "R&D, Engineering",
                                companyName: "Acme\nLabs",
                                addressLines: ["Unit 4; Block B"])

        let vCard = VCardBuilder.vCard(for: card)

        XCTAssertTrue(vCard.contains("FN:Doe\\; Jane"))
        XCTAssertTrue(vCard.contains("TITLE:R&D\\, Engineering"))
        XCTAssertTrue(vCard.contains("ORG:Acme\\nLabs"))
        XCTAssertTrue(vCard.contains("ADR;TYPE=WORK:;;Unit 4\\; Block B"))
    }

    func testLinesAreCRLFSeparated() {
        let vCard = VCardBuilder.vCard(for: BusinessCard(name: "Jane Doe"))

        XCTAssertTrue(vCard.contains("\r\n"))
        XCTAssertFalse(vCard.replacingOccurrences(of: "\r\n", with: "").contains("\n"),
                       "No bare newlines outside CRLF pairs")
    }

    func testQRCodeGeneration() {
        let image = QRCodeRenderer.image(for: "BEGIN:VCARD\r\nEND:VCARD")
        XCTAssertNotNil(image)
        XCTAssertNotNil(image?.cgImage)
    }

    func testQRCardImageMatchesCardAspectRatio() {
        let appearance = BusinessCardAppearance()
        let image = QRCodeRenderer.cardImage(for: "BEGIN:VCARD\r\nEND:VCARD", appearance: appearance)

        XCTAssertNotNil(image)
        if let size = image?.size {
            XCTAssertEqual(size.width / size.height, appearance.cardAspectRatio, accuracy: 0.01)
        }
    }

    func testDemoCardHasNoBundledLogo() {
        XCTAssertNil(BusinessCard.demo.logo, "The kit must not depend on host-app assets")
    }
}
