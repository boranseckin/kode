//
//  AccountDetailView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-21.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.dismiss) var dismiss

    var account: Account

    @State private var secret = ""
    @State private var issuer = ""
    @State private var label = ""
    @State private var email = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Secret Key")) {
                    Text(secret)
                        .lineLimit(1)
                        .colorMultiply(.gray)
                        .textSelection(.enabled)
                }
                
                Section(header: Text("Issuer")) {
                    TextField("Issuer", text: $issuer)
                }
                
                Section(header: Text("Email")) {
                    TextField("Email", text: $email)
                        #if os(iOS)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        #endif
                }
                
                Section(header: Text("Label")) {
                    TextField("Label (Optional)", text: $label)
                }
            }
            .onAppear() {
                secret = account.secret
                issuer = account.issuer
                email = account.email
                label = account.label ?? ""
            }
            .toolbar {
                #if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        var newAccount = account
                        newAccount.issuer = issuer.isEmpty ? account.issuer : issuer
                        newAccount.email = email.isEmpty ? account.email : email
                        newAccount.label = label.isEmpty ? nil : label
                        accountData.modify(account: newAccount)
                        dismiss()
                    }
                }
                #endif
            }
        }
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountDetailView(account: account).environmentObject(accountData)
    }
}
