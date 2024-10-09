//
//  AddAccountView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

#if canImport(CodeScanner)
import CodeScanner
#endif

struct AccountAddView: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.dismiss) var dismiss

    @State private var secret = ""
    @State private var issuer = ""
    @State private var user = ""
    @State private var algorithm = Algorithms.SHA1
    @State private var digits = Digits.SIX
    
    @State private var cameraPermission = true
    
    @State private var showCreateAlert = false
    @State private var showScanAlert = false
    
    private let simulatedData = "otpauth://totp/ACME%20Co:john@example.com?secret=ELAMCYYZMBA7JFDRX4W2NZZ2CRPXH6BF&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30"

    var body: some View {
        VStack {
            #if os(iOS)
            HStack() {
                Spacer()
                Button("Cancel", action: {
                    dismiss()
                })
                .keyboardShortcut(.cancelAction)
            }
            .padding()

            // MARK: QR Code Scanner
            if (cameraPermission) {
                CodeScannerView(codeTypes: [.qr], simulatedData: simulatedData, completion: handleScan)
                    .contentShape(Rectangle())
                    .padding()
                Text("Scan the QR code to add a new account\nor manually enter the details below.")
                .multilineTextAlignment(.center)
            } else {
                Text("Camera access is not permitted. Authorize camera use in the app settings or manually enter the details below.")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                Spacer()
                Button("App Settings", action: {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                })
            }
            #endif
            
            // MARK: Form
            Form {
                Section {
                    HStack {
                        TextField("Secret Key", text: $secret)

                        Divider()

                        Button {
                            #if os(macOS)
                            secret = NSPasteboard.general.string(forType: .string) ?? ""
                            #else
                            if UIPasteboard.general.hasStrings {
                                secret = UIPasteboard.general.string ?? ""
                            }
                            #endif
                        } label: {
                            Image(systemName: "doc.on.clipboard")
                        }
                    }

                    TextField("Issuer", text: $issuer)

                    TextField("User", text: $user)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    #endif
                    
                    Picker("Algorithm", selection: $algorithm) {
                        ForEach(Algorithms.allCases) { algorithm in
                            Text(String(describing: algorithm))
                        }
                    }

                    Picker("Digits", selection: $digits) {
                        ForEach(Digits.allCases) { digits in
                            Text(String(describing: digits))
                        }
                    }
                }
                
                // MARK: Save Button
                #if os(macOS)
                HStack {
                    Spacer()

                    Button("Save", action: {
                        if (handleSubmit(secret: secret, issuer: issuer, user: user, digits: digits, algorithm: algorithm)) {
                            dismiss()
                        } else {
                            print("Manually adding new account failed.")
                            showCreateAlert = true
                        }
                    })
                    .disabled(secret.isEmpty || issuer.isEmpty || user.isEmpty)
                    .keyboardShortcut(.defaultAction)
                    .alert("Account cannot be created", isPresented: $showCreateAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Please verify the secret is valid and try again.")
                    }
                }
                #else
                Button("Save", action: {
                    if (handleSubmit(secret: secret, issuer: issuer, user: user, digits: digits, algorithm: algorithm)) {
                        dismiss()
                    } else {
                        print("Manually adding new account failed.")
                        showCreateAlert = true
                    }
                })
                .disabled(secret.isEmpty || issuer.isEmpty || user.isEmpty)
                .keyboardShortcut(.defaultAction)
                .alert("Account cannot be created", isPresented: $showCreateAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please verify the secret is valid and try again.")
                }
                .alert("Account cannot be created", isPresented: $showScanAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Please verify the QR code is valid and try again.")
                }
                #endif
            }
        }
        #if os(macOS)
        .padding()
        .frame(minWidth: 500)
        #endif
    }
    
    // MARK: Handlers
    func handleSubmit(secret: String, issuer: String, user: String, digits: Digits, algorithm: Algorithms) -> Bool {
        do {
            let account = try createAccount(secret: secret, issuer: issuer, algorithm: algorithm, digits: digits, user: user)
            accountData.add(account: account)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    #if os(iOS)
    func handleScan(result: Result<ScanResult, ScanError>) {
        print(result)
        switch result {
            case .success(let result):
                do {
                    let account = try createAccountFromURIString(string: result.string)
                    accountData.add(account: account)
                    dismiss()
                } catch {
                    print(error)
                    showScanAlert = true
                }
            case .failure(let error):
                switch error {
                    case ScanError.permissionDenied:
                        Task { @MainActor in
                            cameraPermission = false
                        }
                    default:
                        print("Scanning failed: \(error.localizedDescription)")
                        showScanAlert = true
                }
        }
    }
    #endif
}

struct AccountAddView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        AccountAddView().environmentObject(accountData)
    }
}
