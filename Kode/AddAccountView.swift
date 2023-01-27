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

struct AddAccountView: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.dismiss) var dismiss

    @State private var secret = ""
    @State private var issuer = ""
    @State private var label = ""
    @State private var email = ""
    
    @State private var permission = true
    
    @State private var showScanErrorAlert = false

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
            if (permission) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "otpauth://totp/ACME%20Co:john@example.com?secret=ELAMCYYZMBA7JFDRX4W2NZZ2CRPXH6BF&issuer=ACME%20Co&algorithm=SHA1&digits=6&period=30", completion: handleScan)
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
                        #if os(macOS)
                            .frame(width: 370)
                        #endif

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

                    TextField("Email", text: $email)
                    #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                    #endif

                    TextField("Label (Optional)", text: $label)
                }
                
                // MARK: Save Button
                #if os(macOS)
                HStack {
                    Spacer()

                    Button("Save", action: {
                        if (handleSubmit(secret: secret, issuer: issuer, email: email, label: label)) {
                            dismiss()
                        } else {
                            print("Manually adding new account failed.")
                        }
                    })
                    .disabled(secret.isEmpty || issuer.isEmpty || email.isEmpty)
                    .keyboardShortcut(.defaultAction)
                }
                #else
                Button("Save", action: {
                    if (handleSubmit(secret: secret, issuer: issuer, email: email, label: label)) {
                        dismiss()
                    } else {
                        print("Manually adding new account failed.")
                    }
                })
                .disabled(secret.isEmpty || issuer.isEmpty || email.isEmpty)
                .keyboardShortcut(.defaultAction)
                #endif
            }
        }
        #if os(macOS)
        .padding()
        #endif
    }
    
    func handleSubmit(secret: String, issuer: String, email: String, label: String) -> Bool {
        do {
            let account = try createAccount(secret: secret, issuer: issuer, email: email, label: label)
            accountData.add(account: account)
            return true
        } catch {
            print(error)
            return false
        }
    }
    
    #if os(iOS)
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            if let account = try? createAccountFromURIString(string: result.string) {
                accountData.add(account: account)
                dismiss()
            }
        case .failure(let error):
            switch error {
            case ScanError.permissionDenied:
                permission = false
            default: break
            }

            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    #endif
}

struct AddAccountView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        AddAccountView().environmentObject(accountData)
    }
}
