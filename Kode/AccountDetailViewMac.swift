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
    @State private var email = ""

    var body: some View {
        #if os(macOS)
        Form {
            Section(header: Text("Secret Key")) {
                Text(secret)
                    .lineLimit(1)
                    .colorMultiply(.gray)
                    .textSelection(.enabled)
            }
            
            TextField("Issuer", text: $issuer)
            
            TextField("Email", text: $email)
            
            TextField("Label", text: $label)
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
                
                Spacer()

                Button("Save") {
                    var newAccount = account
                    newAccount.issuer = issuer.isEmpty ? account.issuer : issuer
                    newAccount.email = email.isEmpty ? account.email : email
                    newAccount.label = label.isEmpty ? nil : label
                    accountData.modify(account: newAccount)
                    dismiss()
                }
                .disabled(secret.isEmpty || issuer.isEmpty || email.isEmpty)
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding()
        .onAppear() {
            secret = account.secret
            issuer = account.issuer
            email = account.email
            label = account.label ?? ""
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
