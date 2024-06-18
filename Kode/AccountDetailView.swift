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
    @State private var user = ""
    @State private var type = Types.TOTP
    @State private var algorithm = Algorithms.SHA1
    @State private var digits = Digits.SIX
    @State private var showDeleteAlert = false

    var body: some View {
        Form {
            Section(header: Text("Secret Key").font(.caption).foregroundStyle(.gray)) {
                Text(secret)
                    .lineLimit(1)
                    .foregroundColor(.gray)
                    .textSelection(.enabled)
            }
            
            Section(header: Text("Issuer").font(.caption).foregroundStyle(.gray)) {
                TextField("Issuer", text: $issuer)
            }
            
            Section(header: Text("User").font(.caption).foregroundStyle(.gray)) {
                TextField("User", text: $user)
                    #if os(iOS)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    #endif
            }
            
            Section(header: Text("Label").font(.caption).foregroundStyle(.gray)) {
                TextField("Label", text: $label)
            }
            
            Section(header: Text("Advanced").font(.caption).foregroundStyle(.gray)) {
//                Picker("Type", selection: $type) {
//                    ForEach(Types.allCases) { type in
//                        Text(String(describing: type))
//                    }
//                }

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

            Section(header: Text("").font(.caption).foregroundStyle(.gray)) {
                Button("Delete", role: .destructive) {
                    showDeleteAlert.toggle()
                }.alert(isPresented: $showDeleteAlert, content: {
                    Alert(
                        title: Text("Are you sure you want to delete this account?"),
                        message: Text("This action is irreversable!"),
                        primaryButton: .destructive(Text("Yes")) {
                            accountData.remove(at: [accountData.accounts.firstIndex(where: { $0.id == account.id })!])
                            showDeleteAlert = false
                            dismiss()
                        },
                        secondaryButton: .cancel() {
                            showDeleteAlert = false
                        }
                    )
                })
            }
        }
        .onAppear() {
            secret = account.secret
            issuer = account.issuer
            user = account.user
            label = account.label ?? ""
            type = account.type
            algorithm = account.algorithm
            digits = account.digits
        }
        #if os(iOS)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    var newAccount = account
                    newAccount.issuer = issuer.isEmpty ? account.issuer : issuer
                    newAccount.user = user.isEmpty ? account.user : user
                    newAccount.label = label.isEmpty ? nil : label
                    newAccount.type = type
                    newAccount.algorithm = algorithm
                    newAccount.digits = digits
                    accountData.modify(account: newAccount)
                    dismiss()
                }
            }
        }
        #endif
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountDetailView(account: account).environmentObject(accountData)
    }
}
