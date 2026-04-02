# NFC Reader Sample App

A sample iOS application demonstrating how to integrate Daon's NFC SDK to read NFC-chipped travel documents such as biometric passports (ICAO 9303 compliant). The app guides a user through entering their document credentials, then reads the chip over NFC and displays the extracted passport data — including the face photograph — alongside any validation issues.

---

## Table of Contents

- [Purpose](#purpose)
- [Repository Structure](#repository-structure)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [NFC SDK Dependency Setup](#nfc-sdk-dependency-setup)
- [Dependencies](#dependencies)
- [Building the App](#building-the-app)
- [Code Signing](#code-signing)

---

## Purpose

This project serves as a reference implementation for integrating the `DaonNFCSDK` framework into an iOS app. It demonstrates:

- Initialising `IXNFCReader` from the Daon NFC SDK with a license file
- Collecting passport credentials (document number, date of birth, date of expiry) via a SwiftUI form
- Handling the full NFC read lifecycle: progress callbacks via `IXNFCReaderDelegate`, success, and error states
- Displaying structured passport data (personal details, MRZ, face image) returned by the SDK as `IXNFCPassportData`
- Mapping SDK error codes (`IXNFCTagError`) to user-facing messages
- A clean MVVM pattern that keeps all SDK interaction inside a ViewModel, making the UI and business logic cleanly separated

---

## Repository Structure

```
nfc-sdk-ios/
├── Package.swift                      # Swift Package Manager manifest (binary target)
├── Samples/
│   └── SDKSample/
│       ├── SDKSample.xcodeproj/       # Xcode project
│       └── SDKSample/
│           ├── SDKSampleApp.swift     # @main app entry point
│           ├── ContentView.swift      # Input form (document number, DOB, DOE)
│           ├── ContentViewModel.swift # MVVM ViewModel; owns IXNFCReader; all SDK state
│           ├── ResultsView.swift      # Passport data display after a successful read
│           ├── ResultsViewModel.swift # PassportResult model + date formatting
│           ├── license.txt            # Daon SDK license file (loaded at runtime)
│           ├── Info.plist             # NFC usage description and ISO 7816 AIDs
│           ├── SDKSample.entitlements # NFC reader session entitlement
│           ├── Assets.xcassets/       # App icon, brand colours, Daon logo
│           └── Preview Content/       # Xcode preview assets
└── README.md
```

---

## Architecture

The app follows a strict **MVVM** pattern built on SwiftUI:

```
SDKSampleApp (@main)
   │  Launches ContentView inside a WindowGroup
   ▼
ContentView (SwiftUI)
   │  @StateObject → ContentViewModel
   │  Input form: document number, date of birth, date of expiry, active auth toggle
   │  Alerts for validation errors and scan failures
   │  Full-screen cover for ResultsView on successful scan
   ▼
ContentViewModel (@MainActor, ObservableObject)
   │  Owns IXNFCReader (Daon SDK)
   │  Exposes @Published properties consumed by the UI:
   │    - documentNumber, dateOfBirth, dateOfExpiry, activeAuthentication
   │    - validationError / validationTitle   (drives error alert)
   │    - scanError                           (drives scan failure alert)
   │    - passportResult                      (drives results full-screen cover)
   │
   │  IXNFCReaderDelegate translates SDK events into NFC session messages:
   │    tagDataInfoInit / tagDataInfoScan  →  "Hold your iPhone near an NFC enabled document"
   │    tagDataInfoDG1                     →  "Reading Passport data"
   │    tagDataInfoDG2                     →  "Reading Photo"
   │    tagDataInfoDone                    →  "Done"
   │
   │  Completion handler maps IXNFCPassportData → PassportResult
   ▼
ResultsView (SwiftUI)
   │  @StateObject → ResultsViewModel
   │  Scrollable card layout: face image, 12 data fields, issues list
   │  "Scan Again" button dismisses back to ContentView
   ▼
ResultsViewModel (@MainActor, ObservableObject)
   │  Owns PassportResult (value type model)
   │  Provides formatted date strings for display
   ▼
PassportResult (struct, Identifiable)
   Plain value type holding all extracted passport fields
```

Views own their ViewModels via `@StateObject`. All SDK interaction is encapsulated in `ContentViewModel`, meaning the results layer has no SDK dependency.

---

## Requirements

| Component | Version |
|---|---|
| Xcode | 14 or later |
| Swift | 5 |
| Minimum iOS deployment target | 15.0 |
| Targeted devices | iPhone and iPad |
| Strict concurrency | `complete` (Swift 6 forward-compatible) |

A physical iPhone with NFC hardware is required to perform actual passport reads. The UI is fully exercisable in the iOS Simulator, but NFC tag detection will not fire without real hardware.

---

## NFC SDK Dependency Setup

The Daon NFC SDK (`DaonNFCSDK`) is distributed as a pre-built XCFramework via Swift Package Manager. The sample app resolves this dependency through SPM using the `Package.swift` at the repository root.

### 1. Add the SDK package to the Xcode project

1. Open `Samples/SDKSample/SDKSample.xcodeproj` in Xcode.
2. Go to **File → Add Package Dependencies…**
3. Enter the repository URL:
   ```
   https://github.com/daoninc/nfc-sdk-ios
   ```
4. Set the version rule (e.g. **Up to Next Major Version** from `1.3.12`).
5. Add the `DaonNFCSDK` library to the **SDKSample** target.

SPM will download the `DaonNFCSDK.xcframework.zip` from the corresponding GitHub Release and verify its checksum automatically.

### 2. SDK license file

The SDK validates a license at runtime. The license file is bundled in the app's resources. A pre-bundled `license.txt` is located at:

```
Samples/SDKSample/SDKSample/license.txt
```

If you need to use your own license, replace this file. The file is loaded from the app bundle and passed to `IXNFCReader` during initialisation.

### 3. NFC entitlements and Info.plist

The sample app is pre-configured with the required NFC settings:

**Entitlements** (`SDKSample.entitlements`):
```xml
<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>NDEF</string>
    <string>TAG</string>
</array>
```

**Info.plist** — NFC usage description and ISO 7816 Application Identifiers for ICAO e-passports:
```xml
<key>NFCReaderUsageDescription</key>
<string>This app reads NFC passport chips to verify your identity document.</string>

<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
<array>
    <string>A0000002471001</string>
    <string>A0000002472001</string>
    <string>A0000002472002</string>
    <string>A0000002472003</string>
    <string>00000000000000</string>
</array>
```

---

## Dependencies

### Daon NFC SDK

| Framework | Version | Distribution | Purpose |
|---|---|---|---|
| `DaonNFCSDK.xcframework` | `1.3.12` | Swift Package Manager (binary target) | Core NFC passport reading library |

The SDK ships as a self-contained XCFramework with two slices:

| Slice | Architectures | Purpose |
|---|---|---|
| `ios-arm64` | arm64 | Physical device |
| `ios-arm64_x86_64-simulator` | arm64, x86_64 | iOS Simulator |

### System frameworks

The SDK and sample app use Apple system frameworks only — no third-party dependencies beyond the Daon NFC SDK itself:

| Framework | Purpose |
|---|---|
| `SwiftUI` | Declarative UI framework |
| `Foundation` | Core data types, date formatting, string manipulation |
| `CoreNFC` | NFC tag reader sessions (used internally by the SDK) |
| `UIKit` | `UIImage` for face photograph display |

---

## Building the App

### Open in Xcode

The simplest way to build and run is to open the project directly:

```bash
open Samples/SDKSample/SDKSample.xcodeproj
```

Then select a simulator or connected device and press **Cmd+R**. To run on a physical device, you will need to configure your own signing identity — see [Code Signing](#code-signing).

### Debug build (Simulator)

```bash
xcodebuild \
  -project Samples/SDKSample/SDKSample.xcodeproj \
  -scheme SDKSample \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

### Release build

```bash
xcodebuild \
  -project Samples/SDKSample/SDKSample.xcodeproj \
  -scheme SDKSample \
  -configuration Release \
  build
```

### Clean the build

```bash
xcodebuild \
  -project Samples/SDKSample/SDKSample.xcodeproj \
  -scheme SDKSample \
  clean
```

---

## Code Signing

To build and run on your own device, update the **Signing & Capabilities** settings in Xcode:

1. Open the project in Xcode.
2. Select the **SDKSample** target.
3. Go to the **Signing & Capabilities** tab.
4. Change the **Team** to your own Apple Developer team.
5. Update the **Bundle Identifier** if needed to match your provisioning profile.

The NFC Tag Reader capability must be enabled in your provisioning profile. This requires an Apple Developer Program membership — NFC entitlements are not available with free developer accounts.
