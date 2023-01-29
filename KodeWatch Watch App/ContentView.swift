//
//  ContentView.swift
//  KodeWatch Watch App
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountData: AccountData

    var body: some View {
        NavigationView {
            List {
                ForEach(accountData.accounts) { account in
                    NavigationLink("\(account.issuer)") {
                        AccountDetailView(account: account)
                    }
                }
            }
            .navigationTitle("Kode")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        ContentView().environmentObject(accountData)
    }
}
