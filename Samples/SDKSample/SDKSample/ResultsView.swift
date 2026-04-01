import SwiftUI

// MARK: - Results View

struct ResultsView: View {

    @StateObject private var viewModel: ResultsViewModel
    let onScanAgain: () -> Void

    init(result: PassportResult, onScanAgain: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: ResultsViewModel(result: result))
        self.onScanAgain = onScanAgain
    }

    private let pageBackground = Color("AppBackground")
    private let navyBlue = Color("AppNavy")

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    Spacer().frame(height: 24)

                    // Header
                    VStack(spacing: 32) {
                        ResultsIconView()

                        VStack(spacing: 6) {
                            Text("Scan Results")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Passport data successfully read")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                    }

                    Spacer().frame(height: 32)

                    // Face Image card
                    if let image = viewModel.result.faceImage {
                        ResultsCardView {
                            VStack(alignment: .leading, spacing: 12) {
                                ResultsFieldLabel(text: "FACE IMAGE")
                                HStack {
                                    Spacer()
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: 200)
                                    Spacer()
                                }
                            }
                        }
                        Spacer().frame(height: 16)
                    }

                    // Data fields card
                    ResultsCardView {
                        VStack(spacing: 0) {
                            ResultsField(label: "FIRST NAME", value: viewModel.result.firstName)
                            ResultsField(label: "LAST NAME", value: viewModel.result.lastName)
                            ResultsField(label: "DOCUMENT NUMBER", value: viewModel.result.documentNumber)
                            ResultsField(label: "ISSUING STATE", value: viewModel.result.issuingState)
                            ResultsField(label: "GENDER", value: viewModel.result.gender)
                            ResultsField(label: "DATE OF BIRTH", value: viewModel.formattedDateOfBirth)
                            ResultsField(label: "DATE OF EXPIRY", value: viewModel.formattedDateOfExpiry)
                            ResultsField(label: "CERTIFICATE VERIFIED", value: viewModel.result.certificateVerified ? "Yes" : "No")
                            ResultsField(label: "DOCUMENT EXPIRED", value: viewModel.result.documentExpired ? "Yes" : "No")
                            ResultsField(label: "MRZ", value: viewModel.result.mrz, isLast: true)
                        }
                    }

                    // Issues section
                    if !viewModel.result.issues.isEmpty {
                        Spacer().frame(height: 32)

                        // "Issues" divider header
                        HStack {
                            VStack { Divider() }
                            Text("Issues")
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize()
                            VStack { Divider() }
                        }

                        Spacer().frame(height: 16)

                        VStack(spacing: 12) {
                            ForEach(viewModel.result.issues, id: \.self) { issue in
                                IssueRowView(message: issue)
                            }
                        }
                    }

                    Spacer().frame(height: 32)

                    // Scan Again button
                    Button {
                        onScanAgain()
                    } label: {
                        Text("Scan Again")
                            .font(.headline)
                            .foregroundColor(Color("AppButtonLabel"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(navyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
    }
}

// MARK: - Results Icon View

private struct ResultsIconView: View {
    var body: some View {
        Image(systemName: "person.text.rectangle")
            .font(.system(size: 44))
            .foregroundColor(Color("AppNavy"))
            .frame(width: 90, height: 90)
            .background(Color("AppBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - Results Card View

private struct ResultsCardView<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .padding(20)
        .background(Color("AppCardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Results Field Label

private struct ResultsFieldLabel: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
    }
}

// MARK: - Results Field

private struct ResultsField: View {
    let label: String
    let value: String?
    var isLast: Bool = false

    init(label: String, value: String?, isLast: Bool = false) {
        self.label = label
        self.value = value
        self.isLast = isLast
    }

    init(label: String, value: Bool, isLast: Bool = false) {
        self.label = label
        self.value = value ? "Yes" : "No"
        self.isLast = isLast
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            VStack(alignment: .leading, spacing: 4) {
                ResultsFieldLabel(text: label)
                Text(value ?? "—")
                    .font(.body)
                    .foregroundColor(.primary)
            }
            .padding(.vertical, 14)

            if !isLast {
                Divider()
            }
        }
    }
}

// MARK: - Issue Row View

private struct IssueRowView: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.white)
                .font(.body)
                .padding(.top, 2)
            Text(message)
                .font(.body)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        }
        .padding(16)
        .background(Color.red.opacity(0.85))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Preview

#Preview {
    let sampleResult = PassportResult(
        faceImage: nil,
        firstName: "Test",
        lastName: "Test Surname",
        documentNumber: "PE1234567",
        issuingState: "Ireland",
        gender: "MALE",
        dateOfBirth: Calendar.current.date(from: DateComponents(year: 2003, month: 9, day: 4)),
        dateOfExpiry: Calendar.current.date(from: DateComponents(year: 2018, month: 6, day: 3)),
        certificateVerified: false,
        documentExpired: true,
        mrz: "MRZ",
        issues: [
            "ISSUE"
        ]
    )
    ResultsView(result: sampleResult) { }
}
