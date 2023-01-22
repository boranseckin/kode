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
    
    @State private var isShowingDetailView = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                if (account.label != nil) {
                    Text("\(account.label!)")
                }
                
                Text("\(account.issuer)")
                
                Text("\(account.email)")
                    .font(.subheadline)
            }
            
            Spacer()

            Button {
                isShowingDetailView.toggle()
            } label: {
                Image(systemName: "pencil")
                    .font(.title2)
            }.sheet(isPresented: $isShowingDetailView, content: {
                AccountDetailView(account: account)
            })
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingDetailView = true
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
