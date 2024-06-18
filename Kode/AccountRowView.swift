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
        let issuer = account.issuer == "" ? "Unknown" : account.issuer

        Section(
            header: account.label != nil
                ? Text("\(account.label!) • \(issuer)")
                : Text("\(issuer)")
        ) {
            HStack {
                VStack(alignment: .leading) {
                    Text(account.formattedCode())
                        .font(.title)
                        .bold()
                        #if os(macOS)
                        .textSelection(.enabled)
                        #endif
                    
                    
                    Text("\(account.user)")
                        .lineLimit(1)
                        .font(.subheadline)
                }
                Spacer()

                if (tap) {
                    Text("Copied")
                }
                Image(systemName: tap ? "checkmark" : "clipboard")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                #if os(macOS)
                NSPasteboard.general.clearContents()
                NSPasteboard.general.setString(account.code, forType: .string)
                #else
                UIPasteboard.general.string = account.code
                #endif

                withAnimation(.linear(duration: 0.2)) {
                    tap.toggle()
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    withAnimation(.linear(duration: 0.2)) {
                        tap = false
                    }
                }
            }
            #if os(iOS)
            .scaleEffect(tap ? 1.01 : 1)
            #endif
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
