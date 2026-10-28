//
//  VCardBuilder.swift
//  BusinessCardKit
//

import Foundation

/// Builds a vCard 3.0 (RFC 2426) string from a card — the version with the
/// broadest scanner support. Empty fields are skipped, values are escaped,
/// and lines are joined with CRLF as the spec requires.
///
/// Display-only fields stay out of the vCard: `pronouns` (no standard
/// property) and `photo`/`logo` (QR capacity is far too small for images).
enum VCardBuilder {

    static func vCard(for card: BusinessCard) -> String {
        var lines = ["BEGIN:VCARD", "VERSION:3.0"]

        // Identity. N is structured (family;given;middle;prefix;suffix).
        // Splitting a display name into components is unreliable across
        // cultures, so the full name goes in the family slot — the common
        // convention when only a display name exists — and credentials go
        // in the suffix slot.
        lines.append("FN:\(escape(card.name))")
        lines.append("N:\(escape(card.name));;;;\(escape(card.credentials ?? ""))")

        // Role. ORG carries organizational units after the company name.
        appendIfPresent("TITLE", card.designation, to: &lines)
        if let company = card.companyName, !company.isEmpty {
            var org = "ORG:\(escape(company))"
            if let department = card.department, !department.isEmpty {
                org += ";\(escape(department))"
            }
            lines.append(org)
        }

        // Contact
        appendIfPresent("TEL;TYPE=CELL", card.mobileNumber, to: &lines)
        appendIfPresent("TEL;TYPE=CELL", card.secondaryMobileNumber, to: &lines)
        appendIfPresent("TEL;TYPE=WORK", card.landlineNumber, to: &lines)
        appendIfPresent("TEL;TYPE=FAX", card.faxNumber, to: &lines)
        appendIfPresent("EMAIL", card.email, to: &lines)
        appendIfPresent("EMAIL;TYPE=WORK", card.secondaryEmail, to: &lines)
        appendIfPresent("URL", card.website, to: &lines)

        // Address
        let addressLines = card.addressLines.filter { !$0.isEmpty }
        if !addressLines.isEmpty {
            let components = addressLines.map(escape).joined(separator: ";")
            lines.append("ADR;TYPE=WORK:;;\(components)")
        }

        // Social profiles — the de-facto convention Apple Contacts uses.
        appendIfPresent("X-SOCIALPROFILE;TYPE=linkedin", card.linkedIn, to: &lines)
        appendIfPresent("X-SOCIALPROFILE;TYPE=instagram", card.instagram, to: &lines)
        appendIfPresent("X-SOCIALPROFILE;TYPE=twitter", card.twitter, to: &lines)
        appendIfPresent("X-SOCIALPROFILE;TYPE=whatsapp", card.whatsappNumber, to: &lines)

        // Everything informational lands in a single NOTE.
        let notes = [card.companyTagline,
                     card.licenseNumber.map { "License: \($0)" }]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        if !notes.isEmpty {
            lines.append("NOTE:\(escape(notes.joined(separator: "\n")))")
        }

        lines.append("END:VCARD")
        return lines.joined(separator: "\r\n")
    }

    // MARK: - Helpers

    /// Appends `property:value` when the value is non-empty.
    private static func appendIfPresent(_ property: String, _ value: String?, to lines: inout [String]) {
        guard let value, !value.isEmpty else { return }
        lines.append("\(property):\(escape(value))")
    }

    /// Escapes the characters RFC 2426 reserves inside property values.
    private static func escape(_ value: String) -> String {
        value
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: ",", with: "\\,")
            .replacingOccurrences(of: ";", with: "\\;")
    }
}
