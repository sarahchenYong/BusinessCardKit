# BusinessCardKit

A self-contained Swift package that renders digital business cards in a
self-sizing bottom sheet, with sharing built in: snapshot the card, or share
a scannable QR code carrying the contact as a vCard.

- **Zero app coupling** — you inject the data (`BusinessCard`) and the look
  (`BusinessCardAppearance`); the kit knows nothing about your networking,
  models, or session.
- **Designer-editable layouts** — both card faces are XIBs. Point the
  appearance at your own nibs to restyle a card without touching kit code.
- **Sharing built in** — long-press a card for *Share Card* (image),
  *Share QR* and *View QR* (vCard 3.0, escaped per RFC 2426).
- **Async-friendly logos** — present immediately with a placeholder and call
  `updateLogo(_:)` when a remote logo arrives; it cross-fades in place.

## Requirements

iOS 16+, Swift 5.9+.

## Installation

Add `https://github.com/sarahchenYong/BusinessCardKit.git` in Xcode
under **File → Add Package Dependencies…**, using version **1.0.0** or later,
and import:

```swift
import BusinessCardKit
```

## Usage

```swift
let card = BusinessCard(name: "Jane Doe",
                        designation: "Engineer",
                        companyName: "Acme",
                        addressLines: ["6th Floor, Tower A", "Dubai, UAE"],
                        mobileNumber: "+971 50 000 0000",
                        email: "jane@acme.com",
                        website: "www.acme.com",
                        logo: UIImage(named: "company-logo"))

let controller = BusinessCardViewController(cards: [card])
controller.presentCard(from: self)
```

### Remote logos — never block presentation

```swift
controller.presentCard(from: self)          // opens instantly with the placeholder

myImageLoader.load(logoURL) { image in      // any loader you already use
    controller.updateLogo(image)            // cross-fades onto the presented card
}
```

### Appearance

Every color, font, radius and the card aspect ratio is injectable:

```swift
var appearance = BusinessCardAppearance(textColor: .white,
                                        cardBackgroundColor: .black,
                                        cardAspectRatio: 1.6)
appearance.showsBackSide = true             // renders the back face too
```

To replace a layout entirely, copy the bundled XIB, edit it, and point the
appearance at it — outlet names are the contract:

```swift
appearance.frontNibName = "MyCardFront"     // File's Owner: BusinessCardView
appearance.backNibName = "MyCardBack"       // File's Owner: BusinessCardBackView
appearance.nibBundle = .main
```

Every outlet is optional — connect only what your design shows, the rest
render nowhere and are skipped in the vCard when empty:

| Group | Outlets |
|---|---|
| Identity | `photoImageView`, `nameLabel`, `nameArabicLabel`, `credentialsLabel`, `pronounsLabel` |
| Role | `designationLabel`, `designationArabicLabel`, `departmentLabel`, `companyLabel`, `companyArabicLabel`, `taglineLabel` |
| Contact | `mobileLabel`, `secondaryMobileLabel`, `whatsappLabel`, `landlineLabel`, `faxLabel`, `emailLabel`, `secondaryEmailLabel`, `websiteLabel` |
| Address | `officeStackView` (one injected label per line) *or* `addressLabel` (single multiline) |
| Social | `linkedInLabel`, `instagramLabel`, `twitterLabel` |
| Regulatory | `licenseLabel` |
| Branding | `logoImageView` (template-tinted, on both faces) |

The QR vCard carries every populated field except display-only ones:
`pronouns` (no standard property) and `photo`/`logo` (QR capacity).

### Events

Per-action hooks let the host attach analytics (or anything else) with its
own event vocabulary — the kit defines none:

```swift
controller.onShareCard = { log("card shared") }
controller.onShareQRCode = { log("qr shared") }
controller.onViewQRCode = { log("qr viewed") }
```

### Demo mode

`BusinessCardViewController(cards: [card], showDemoData: true)` renders a
fully populated sample card (borrowing your first card's logo), so layout
changes can be reviewed before real data exists.

### Localization

The sheet's strings are plain public properties — set them from your own
localization system:

```swift
controller.shareHintText = NSLocalizedString("card.hint", comment: "")
controller.shareActionTitle = NSLocalizedString("card.share", comment: "")
```

## Testing

```bash
xcodebuild test -scheme BusinessCardKit -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```
