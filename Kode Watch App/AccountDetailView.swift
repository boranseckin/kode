//
//  AccountDetailView.swift
//  Kode Watch App
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var accountData: AccountData

    var account: Account

    var body: some View {
        VStack {
            if (account.label != nil) {
                Text("\(account.label!)")
            }
            
            Text("\(account.code)")
                .font(.largeTitle)

            Text("\(account.issuer)")

            Text("\(account.email)")
                .font(.footnote)
        }
        .onAppear() {
            accountData.updateCode(account: account)
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
