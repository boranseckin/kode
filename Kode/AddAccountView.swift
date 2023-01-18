//
//  AddAccountView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.dismiss) var dismiss

    @State private var secret = ""
    @State private var issuer = ""
    @State private var name = ""
    @State private var email = ""

    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Secret Key", text: $secret)
                    TextField("Issuer (Optional)", text: $issuer)
                    TextField("Account Name", text: $name)
                    TextField("Email", text: $email)
                }

                Button("Save", action: {
                    if accountData.add(secret: secret, issuer: issuer, name: name, email: email) {
                        dismiss()
                    } else {
                        //TODO: Error messages
                    }
                })
            }
        }
        .navigationTitle("New Account")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        AddAccountView().environmentObject(accountData)
    }
}
