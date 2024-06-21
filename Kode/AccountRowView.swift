//
//  AccountRowView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

#if !os(macOS)
import SwiftUI
import Accounts

struct AccountRowView: View {
    @EnvironmentObject var accountData: AccountData
    
    @State var tap = false

    var account: Account

    var body: some View {
        let issuer = account.issuer == "" ? "Unknown" : account.issuer

        VStack(alignment: .leading) {
            HStack {
                VStack(alignment: .leading) {
                    Text(account.label != nil ? "\(account.label!) • \(issuer)" : issuer)
                        .lineLimit(1)
                        .font(.title3)
                    
                    Text("\(account.user)")
                        .lineLimit(1)
                        .font(.caption)
                }
                
                Spacer()

                if (tap) {
                    Text("Copied")
                        .font(.title3)
                } else {
                    Text(account.formattedCode())
                        .font(.title)
                        .bold()
                        .monospaced()
                        .lineLimit(1)
                        .fixedSize()
                }
                
                Image(systemName: tap ? "checkmark" : "clipboard")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIPasteboard.general.string = account.code

                withAnimation(.linear(duration: 0.2)) {
                    tap.toggle()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.linear(duration: 0.2)) {
                        tap = false
                    }
                }
            }
//            .scaleEffect(tap ? 1.01 : 1)
        }
    }
}

struct AccountRowView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountRowView(account: account).environmentObject(accountData)
    }
}
#endif
