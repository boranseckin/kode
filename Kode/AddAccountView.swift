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
        NavigationView {
            VStack {
                HStack() {
                    Spacer()
                    Button("Cancel", action: {
                        dismiss()
                    })
                }
                .padding()

                #if os(iOS)
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
                        TextField("Email", text: $email)
                        #if os(iOS)
                            .textInputAutocapitalization(.never)
                            .keyboardType(.emailAddress)
                        #endif
                        TextField("Label (Optional)", text: $label)
                    }
                    
                    Button("Save", action: {
                        if accountData.add(account: Account(id: UUID(), secret: secret, issuer: issuer, label: label, email: email)) {
                            dismiss()
                        } else {
                            print("Manually adding new account failed.")
                        }
                    }).disabled(secret.isEmpty || issuer.isEmpty || email.isEmpty)
                }
            }
        }
        .navigationTitle("New Account")
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
    
    #if os(iOS)
    func handleScan(result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let result):
            if let account = try? createAccountFromURIString(string: result.string) {
                if accountData.add(account: account) {
                    dismiss()
                } else {
                    print("Adding new account failed.")
                }
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
