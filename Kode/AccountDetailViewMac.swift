//
//  AccountDetailViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct AccountDetailViewMac: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.dismiss) var dismiss

    var account: Account

    @State private var secret = ""
    @State private var issuer = ""
    @State private var label = ""
    @State private var user = ""
    @State private var algorithm = Algorithms.SHA1
    @State private var digits = Digits.SIX

    var body: some View {
        #if os(macOS)
        Form {
            Section(header: Text("Secret Key")) {
                Text(secret)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    .textSelection(.enabled)
            }
            
            TextField("Issuer", text: $issuer)
            
            TextField("User", text: $user)
            
            TextField("Label", text: $label)
            
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
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()

                Button("Save") {
                    var newAccount = account
                    newAccount.issuer = issuer.isEmpty ? account.issuer : issuer
                    newAccount.user = user.isEmpty ? account.user : user
                    newAccount.label = label.isEmpty ? nil : label
                    newAccount.algorithm = algorithm
                    newAccount.digits = digits
                    accountData.modify(account: newAccount)
                    dismiss()
                }
                .disabled(secret.isEmpty || issuer.isEmpty || user.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .onAppear() {
            secret = account.secret
            issuer = account.issuer
            user = account.user
            label = account.label ?? ""
            algorithm = account.algorithm
            digits = account.digits
        }
        #endif
    }
}

struct AccountDetailViewMac_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountDetailViewMac(account: account).environmentObject(accountData)
    }
}
