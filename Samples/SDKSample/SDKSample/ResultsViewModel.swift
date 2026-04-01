import SwiftUI

// MARK: - Passport Result

// PassportResult is always created and consumed on @MainActor. It holds
// UIImage (not Sendable), so @unchecked Sendable is used to satisfy the
// concurrency checker — safe because no cross-actor sharing occurs.
struct PassportResult: Identifiable, @unchecked Sendable {
    let id = UUID()
    var faceImage: UIImage?
    var firstName: String?
    var lastName: String?
    var documentNumber: String?
    var documentCode: String?
    var nationality: String?
    var issuingState: String?
    var gender: String?
    var dateOfBirth: Date?
    var dateOfExpiry: Date?
    var certificateVerified: Bool
    var documentExpired: Bool
    var mrz: String?
    var issues: [String]

    init(
        faceImage: UIImage? = nil,
        firstName: String? = nil,
        lastName: String? = nil,
        documentNumber: String? = nil,
        documentCode: String? = nil,
        nationality: String? = nil,
        issuingState: String? = nil,
        gender: String? = nil,
        dateOfBirth: Date? = nil,
        dateOfExpiry: Date? = nil,
        certificateVerified: Bool = false,
        documentExpired: Bool = false,
        mrz: String? = nil,
        issues: [String] = []
    ) {
        self.faceImage = faceImage
        self.firstName = firstName
        self.lastName = lastName
        self.documentNumber = documentNumber
        self.documentCode = documentCode
        self.nationality = nationality
        self.issuingState = issuingState
        self.gender = gender
        self.dateOfBirth = dateOfBirth
        self.dateOfExpiry = dateOfExpiry
        self.certificateVerified = certificateVerified
        self.documentExpired = documentExpired
        self.mrz = mrz
        self.issues = issues
    }
}

// MARK: - Results View Model

@MainActor
final class ResultsViewModel: ObservableObject {

    let result: PassportResult

    init(result: PassportResult) {
        self.result = result
    }

    // MARK: - Formatted values

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var formattedDateOfBirth: String? {
        result.dateOfBirth.map { Self.dateFormatter.string(from: $0) }
    }

    var formattedDateOfExpiry: String? {
        result.dateOfExpiry.map { Self.dateFormatter.string(from: $0) }
    }
}
