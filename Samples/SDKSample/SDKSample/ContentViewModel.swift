import Foundation

import DaonNFCSDK

// MARK: - Content View Model

@MainActor
final class ContentViewModel: ObservableObject {

    var isNFCSupported: Bool { nfcSupportedOverride ?? IXNFCReader.isSupported() }

    @Published var documentNumber: String = ""
    @Published var dateOfBirth: Date? = nil
    @Published var dateOfExpiry: Date? = nil
    @Published var activeAuthentication: Bool = false
    @Published var validationTitle: String? = nil
    @Published var validationError: String? = nil
    @Published var scanError: String? = nil
    @Published var passportResult: PassportResult? = nil

    private var nfcReader: IXNFCReader?
    private var isScanning = false
    private let nfcSupportedOverride: Bool?

    // MARK: Initialization
    
    init(nfcSupportedOverride: Bool? = nil) {
        self.nfcSupportedOverride = nfcSupportedOverride
    }

    // MARK: - Actions

    func startNFCScan() {
        guard !isScanning else { return }

        let trimmedDocumentNumber = documentNumber.trimmingCharacters(in: .whitespaces)
        guard (1...9).contains(trimmedDocumentNumber.count) else {
            validationTitle = "Invalid Input"
            validationError = "Document number must be between 1 and 9 characters."
            return
        }
        
        guard let dateOfBirth else {
            validationTitle = "Invalid Input"
            validationError = "Please select a date of birth."
            return
        }
        
        guard let dateOfExpiry else {
            validationTitle = "Invalid Input"
            validationError = "Please select a date of expiry."
            return
        }
        
        isScanning = true

        // Trigger NFC scan via SDK

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

        // Opt in to face image retrieval from Data Group 2 (DG2).
        // Omit this call if you do not need the face photo.
        parameters.set(photo: true)

        if activeAuthentication {
            // Active Authentication requires an 8-byte challenge.
            // In production, request this challenge from your server so the
            // response can be verified server-side. A random local challenge
            // is used here for demonstration purposes only.
            parameters.set(challenge: generateRandomUInt8Array(8))
        }

        parameters.setAuthenticationType(.paceThenBac)
        
        // Start the NFC read. The completion handler fires on the main queue
        // and delivers IXNFCTagData, which must be downcast to IXNFCPassportData
        // for passport-specific fields (photo, MRZ, issues, etc.).
        nfcReader?.read(parameters: parameters) { @MainActor [weak self] data, error in
            if let error {
                // Silently ignore user-initiated cancellation of the NFC dialog.
                if error._code == IXNFCTagError.UserCanceled._code {
                    self?.nfcReader = nil
                    self?.isScanning = false
                    return
                }

                self?.scanError = error.localizedDescription
            } else if let passportData = data as? IXNFCPassportData {
                self?.passportResult = self?.passportResult(from: passportData)
            } else {
                self?.scanError = "Invalid data returned from NFC scan."
            }

            self?.nfcReader = nil
            self?.isScanning = false
        }
    }

    // MARK: - Passport Result Mapping

    // Map the SDK's IXNFCPassportData to the app's PassportResult model.
    // issues() returns non-fatal SDK warnings (e.g. certificate chain problems)
    // as an array of IXNFCIssue objects, each with a human-readable message.
    private func passportResult(from data: IXNFCPassportData) -> PassportResult {
        PassportResult(
            faceImage: data.photo,
            firstName: data.firstName,
            lastName: data.lastName,
            documentNumber: data.documentNumber,
            documentCode: data.documentCode,
            nationality: data.nationality,
            issuingState: data.state,
            gender: data.gender,
            dateOfBirth: data.dateOfBirth,
            dateOfExpiry: data.dateOfExpiry,
            certificateVerified: data.isCertificateVerified,
            documentExpired: data.isExpired,
            mrz: data.mrz,
            issues: data.issues().map { $0.message }
        )
    }

    // MARK: - Active Authentication Challenge Generation

    // Generates a random 8-byte challenge for Active Authentication.
    // In production, replace this with a server-issued challenge so the
    // chip's response can be verified server-side.
    private func generateRandomUInt8Array(_ size: Int) -> [UInt8] {
        var ret: [UInt8] = []
        for _ in 0 ..< size {
            ret.append(UInt8(arc4random_uniform(UInt32(UInt8.max) + 1)))
        }
        return ret
    }
}

// MARK: - IXNFCReaderDelegate

// readerDidUpdate(info:) is called throughout the scan with progress codes.
// Return a string to update the NFC system dialog message, or nil to keep
// the current message. Use the tagDataInfo constants on IXNFCPassportData
// to identify each phase of the read.
extension ContentViewModel: @MainActor IXNFCReaderDelegate {
    func readerDidUpdate(info: IXNFCTagReaderInfo) -> String? {
        switch info.code {
            case IXNFCPassportData.tagDataInfoInit, IXNFCPassportData.tagDataInfoScan:
                return "Hold your iPhone near an NFC enabled document"
            case IXNFCPassportData.tagDataInfoDG1:
                return "Reading Passport data"
            case IXNFCPassportData.tagDataInfoDG2:
                return "Reading Photo"
            case IXNFCPassportData.tagDataInfoDone:
                return "Done"
            default:
                return "Reading"
        }
    }
}
