//
//  AccountRowView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI
import Accounts

struct AccountRowView: View {
    @EnvironmentObject var accountData: AccountData
    
    @State var tap = false

    var account: Account
    var progress: Double

    var body: some View {
        Section(header: account.issuer.isEmpty ? Text("\(account.name)") : Text("\(account.name) • \(account.issuer)")) {
            VStack(alignment: .leading) {
                HStack {
                    Text("\(account.code)")
                        .font(.title)
                        .bold()

                    Spacer()

                    if (tap) {
                        Text("Copied")
                    }
                    Image(systemName: tap ? "checkmark" : "clipboard")
                }
                
                Text("\(account.email)")
                    .font(.subheadline)

                ProgressView(value: progress, total: 30)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIPasteboard.general.string = account.code

                tap = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    tap = false
               }
            }
            .scaleEffect(tap ? 1.05 : 1)
            .animation(.spring(response: 0.4, dampingFraction: 0.6), value: tap)
        }
    }
}

struct AccountRowView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example
    static let progress = 15.0

    static var previews: some View {
        AccountRowView(account: account, progress: progress).environmentObject(accountData)
    }
}
