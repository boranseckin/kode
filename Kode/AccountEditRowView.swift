//
//  AccountEditRowView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-21.
//

import SwiftUI
import Accounts

struct AccountEditRowView: View {
    @EnvironmentObject var accountData: AccountData

    var account: Account

    var body: some View {
        VStack(alignment: .leading) {
            if (account.label != nil) {
                Text("\(account.label!)")
            }

            Text("\(account.issuer)")
            
            Text("\(account.email)")
                .font(.subheadline)
        }
    }
}

struct AccountEditRowView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountEditRowView(account: account).environmentObject(accountData)
    }
}
