//
//  AccountDetailView.swift
//  Kode Watch App
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct AccountDetailView: View {
    @EnvironmentObject var accountData: AccountData

    @State private var progress = 30.0

    var account: Account

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            VStack {
                if (account.label != nil) {
                    Text("\(account.label!)")
                }
                
                Text("\(account.code)")
                    .font(.largeTitle)

                Text("\(account.issuer)")
                    .lineLimit(1)
                    .frame(width: 150)

                Text("\(account.email)")
                    .lineLimit(1)
                    .font(.footnote)
                    .frame(width: 135)
            }
            .onAppear() {
                accountData.updateCode(account: account)
            }
            
            ProgressView(value: progress, total: 30)
                .progressViewStyle(CustomCircularProgressViewStyle())
                .onReceive(timer) { time in
                    progress = 30 - Double(Calendar.current.component(.second, from: time) % 30)
                    
                    let seconds = Calendar.current.component(.second, from: time)
                    if (seconds == 0 || seconds == 30) {
                        accountData.updateCode(account: account)
                    }
                }
        }
        .padding(.top)
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example

    static var previews: some View {
        AccountDetailView(account: account).environmentObject(accountData)
    }
}

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            Circle()
                .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3))
                .rotationEffect(.degrees(-90))
        }
    }
}
