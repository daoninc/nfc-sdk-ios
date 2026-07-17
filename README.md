# NFC SDK

The NFC SDK can be used to read NFC-chipped travel documents such as biometric passports (ICAO 9303 compliant) on iOS mobile devices. The SDK handles the full NFC read lifecycle and returns structured passport data including personal details, MRZ, and face photograph.

## License
The NFC SDK requires a license that is bound to an application identifier. Contact Daon Support or Sales to request a license.

## Sample

**Samples/SDKSample** contains a reference sample application demonstrating passport reading via NFC, including credential entry, chip reading, and display of extracted passport data.

## Swift Package Manager

The NFC SDK is distributed as a pre-built XCFramework via Swift Package Manager. The sample app resolves this dependency through SPM using the Package.swift at the repository root. 

To add the NFC SDK to your own application:
1. Navigate to File → Add Package Dependencies…
2. Enter the repository URL: https://github.com/daoninc/nfc-sdk-ios
3. Set the dependency rule (e.g. Up to Next Major Version).
4. Add the DaonNFCSDK library to your app target.

SPM will download the DaonNFCSDK.xcframework.zip from the corresponding GitHub Release and verify its checksum automatically.

## API

Add the following import:

```swift
import DaonNFCSDK
```

### Initialize

```swift
// Initialise the reader with your Daon-issued license string or a path
// to a license file. If neither is provided, the SDK defaults to loading
// license.txt from your app bundle automatically.
nfcReader = IXNFCReader()

// Assign the delegate to receive progress callbacks during the scan.
nfcReader?.delegate = self

// Build the passport parameters using the three MRZ fields required
// for BAC (Basic Access Control) or PACE chip authentication.
let parameters = IXNFCPassportParameters(documentNumber: documentNumber,
                                       dateOfBirth: dateOfBirth,
                                       dateOfExpiry: dateOfExpiry)
```

### Read a passport

```swift
// Start the NFC read. The completion handler fires on the main queue
// and delivers IXNFCTagData, which must be downcast to IXNFCPassportData
// for passport-specific fields (photo, MRZ, issues, etc.).
nfcReader?.read(parameters: parameters) { @MainActor [weak self] data, error in
   if let error {
         // Handle error...
   } else if let passportData = data as? IXNFCPassportData {
         // Handle success...
   } else {
         print("Invalid data returned from NFC scan.")
   }

   self?.nfcReader = nil
}
```

See the [NFC SDK Documentation](https://developer.identityx-cloud.com/client/nfc/ios/) for more information.
