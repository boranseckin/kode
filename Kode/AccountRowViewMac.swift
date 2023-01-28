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
    var progress: Double

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
                Text("\(account.code)")
                    .font(.title)
                    .bold()
                    .textSelection(.enabled)
                
                Spacer()
                
                if (tap) {
                    Text("Copied")
                }
                Image(systemName: tap ? "checkmark" : "clipboard")
            }
            
            Text("\(account.email)")
                .lineLimit(1)
                .font(.subheadline)

            ProgressView(value: progress, total: 30)
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
    static let progress = 15.0

    static var previews: some View {
        AccountRowViewMac(account: account, progress: progress)
            .environmentObject(accountData)
    }
}
