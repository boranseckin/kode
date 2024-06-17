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
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: IndexSet?

    var body: some View {
        HStack {
            #if os(macOS)
            Image(systemName: "line.3.horizontal")
            #endif
            
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
                Image(systemName: "slider.horizontal.3")
                    #if !os(macOS)
                    .font(.title2)
                    #endif
            }.sheet(isPresented: $isShowingDetailView) {
                #if os(iOS)
                NavigationView {
                    AccountDetailView(account: account)
                }
                #else
                AccountDetailViewMac(account: account)
                    .frame(width: 400)
                #endif
            }
            
            #if os(macOS)
            Button {
                showDeleteAlert.toggle()
            } label: {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }.alert(isPresented: $showDeleteAlert, content: {
                Alert(
                    title: Text("Are you sure you want to delete this account?"),
                    message: Text("This action is irreversable!"),
                    primaryButton: .destructive(Text("Yes")) {
                        accountData.remove(at: [accountData.accounts.firstIndex(where: { $0.id == account.id })!])
                        toBeDeleted = nil
                        showDeleteAlert = false
                    },
                    secondaryButton: .cancel() {
                        toBeDeleted = nil
                        showDeleteAlert = false
                    }
                )
            })
            #endif
        }
        #if os(iOS)
        .contentShape(Rectangle())
        .onTapGesture {
            isShowingDetailView = true
        }
        #endif
    }
}

struct AccountEditRowView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountEditRowView(account: account).environmentObject(accountData)
    }
}
