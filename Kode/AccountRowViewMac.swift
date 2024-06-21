//
//  AccountRowViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-28.
//

#if os(macOS)
import SwiftUI

struct AccountRowViewMac: View {
    @EnvironmentObject var accountData: AccountData
    
    @State var tap = false
    
    var account: Account

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(account.label != nil ? "\(account.label!) • \(account.issuer)" : "\(account.issuer)")
                    .font(.title3)
                    .bold()
                    .textSelection(.enabled)
                    .lineLimit(1)

                Text("\(account.user)")
                    .lineLimit(1)
                    .font(.subheadline)
                    .textSelection(.enabled)
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
            }

            Image(systemName: tap ? "checkmark" : "clipboard")
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
    }
}

struct AccountRowViewMac_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountRowViewMac(account: account).environmentObject(accountData)
    }
}
#endif
