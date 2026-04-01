import SwiftUI

// MARK: - Content View

struct ContentView: View {

    @StateObject private var viewModel: ContentViewModel
    @FocusState private var isDocumentNumberFocused: Bool

    init(viewModel: ContentViewModel = ContentViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    private let navyBlue = Color("AppNavy")
    private let pageBackground = Color("AppBackground")

    var body: some View {
        ZStack {
            pageBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer().frame(height: 24)

                // Header
                VStack(spacing: 32) {
                    AppIconView()

                    VStack(spacing: 6) {
                        Text("Passport NFC Reader")
                            .font(.title)
                            .fontWeight(.bold)

                        Text(viewModel.isNFCSupported
                             ? "Enter your document details to begin scanning"
                             : "NFC scanning is not available on this device")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }

                Spacer().frame(height: 32)

                if viewModel.isNFCSupported {
                    // Form card
                    VStack(spacing: 14) {
                        // Document Number
                        HStack(spacing: 12) {
                            Image(systemName: "creditcard")
                                .foregroundColor(.secondary)
                            TextField("Document Number", text: $viewModel.documentNumber)
                                .keyboardType(.asciiCapable)
                                .textInputAutocapitalization(.characters)
                                .autocorrectionDisabled(true)
                                .focused($isDocumentNumberFocused)
                                .submitLabel(.done)
                                .onSubmit {
                                    isDocumentNumberFocused = false
                                }
                        }
                        .fieldStyle()

                        // Date of Birth
                        DateInputField(placeholder: "Date of Birth", date: $viewModel.dateOfBirth)

                        // Date of Expiry
                        DateInputField(placeholder: "Date of Expiry", date: $viewModel.dateOfExpiry)

                        Divider()

                        // Active Authentication
                        Toggle(isOn: $viewModel.activeAuthentication) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Active Authentication")
                                    .font(.body)
                                Text("Sends a nonce challenge to the chip")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .tint(Color("AppNavy"))

                    }
                    .padding(20)
                    .background(Color("AppCardBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    Spacer().frame(height: 32)

                    // Start NFC Scan button
                    Button {
                        viewModel.startNFCScan()
                    } label: {
                        Text("Start NFC Scan")
                            .font(.headline)
                            .foregroundColor(Color("AppButtonLabel"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(navyBlue)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                } else {
                    // NFC unavailable
                    NFCUnavailableView()
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 40)
        }
        .onTapGesture {
            isDocumentNumberFocused = false
        }
        .alert("Missing Information", isPresented: Binding(
            get: { viewModel.validationError != nil },
            set: { if !$0 { viewModel.validationError = nil } }
        ), actions: {
            Button("OK") { viewModel.validationError = nil }
        }, message: {
            Text(viewModel.validationError ?? "")
        })
        .alert("Scan Failed", isPresented: Binding(
            get: { viewModel.scanError != nil },
            set: { if !$0 { viewModel.scanError = nil } }
        ), actions: {
            Button("OK") { viewModel.scanError = nil }
        }, message: {
            Text(viewModel.scanError ?? "")
        })
        .fullScreenCover(item: $viewModel.passportResult) { result in
            ResultsView(result: result) {
                viewModel.passportResult = nil
            }
        }
    }
}

// MARK: - App Icon View

private struct AppIconView: View {

    var body: some View {
        Image("DaonLogo")
            .resizable()
            .scaledToFit()
            .frame(height: 50)
            .clipShape(RoundedRectangle(cornerRadius: 22))
    }
}

// MARK: - NFC Unavailable View

private struct NFCUnavailableView: View {

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "antenna.radiowaves.left.and.right.slash")
                .font(.system(size: 48))
                .foregroundColor(.secondary)

            Text("NFC Not Available")
                .font(.headline)

            Text("This device does not support NFC reading. A physical iPhone with NFC hardware is required.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Color("AppCardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Date Input Field

private struct DateInputField: View {

    let placeholder: String
    @Binding var date: Date?

    @State private var showPicker = false
    @State private var tempDate = Date()

    private static let displayFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()

    var body: some View {
        HStack {
            Text(date.map { Self.displayFormatter.string(from: $0) } ?? placeholder)
                .foregroundColor(date == nil ? .secondary : .primary)
            Spacer()
            Image(systemName: "calendar")
                .foregroundColor(.secondary)
        }
        .fieldStyle()
        .onTapGesture {
            tempDate = date ?? Date()
            showPicker = true
        }
        .sheet(isPresented: $showPicker) {
            DatePickerSheet(placeholder: placeholder, date: $tempDate) {
                date = tempDate
                showPicker = false
            }
            .modifier(MediumSheetModifier())
        }
    }
}

// MARK: - Date Picker Sheet

private struct DatePickerSheet: View {

    let placeholder: String
    @Binding var date: Date
    let onDone: () -> Void

    var body: some View {
        NavigationView {
            DatePicker("", selection: $date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding(.horizontal)
                .navigationTitle(placeholder)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done", action: onDone)
                    }
                }
        }
    }
}

// MARK: - View Modifiers

private struct MediumSheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }
}

private extension View {
    func fieldStyle() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
            .background(Color("AppFieldBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(Color.gray.opacity(0.3)))
    }
}

// MARK: - Preview

#Preview("NFC Available") {
    ContentView(viewModel: ContentViewModel(nfcSupportedOverride: true))
}

#Preview("NFC Unavailable") {
    ContentView(viewModel: ContentViewModel(nfcSupportedOverride: false))
}
