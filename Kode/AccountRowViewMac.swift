//
//  AccountRowViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct AccountRowViewMac: View {
    @EnvironmentObject var accountData: AccountData
    
    @State var tap = false
    
    var account: Account

    var body: some View {
        #if os(macOS)
        VStack(alignment: .leading) {
            if (account.label != nil) {
                Text("\(account.label!) • \(account.issuer)")
                    .font(.subheadline)
            } else {
                Text("\(account.issuer)")
                    .font(.subheadline)
            }

            HStack {
                Text(account.formattedCode())
                    .font(.title)
                    .bold()
                    .textSelection(.enabled)
                
                Spacer()
                
                if (tap) {
                    Text("Copied")
                }
                Image(systemName: tap ? "checkmark" : "clipboard")
            }
            
            Text("\(account.user)")
                .lineLimit(1)
                .font(.subheadline)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(account.code, forType: .string)

            withAnimation(.linear(duration: 0.2)) {
                tap.toggle()
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                withAnimation(.linear(duration: 0.2)) {
                    tap = false
                }
            }
        }
        #endif
    }
}

struct AccountRowViewMac_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountRowViewMac(account: account).environmentObject(accountData)
    }
}
