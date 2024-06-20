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
        ZStack(alignment: .center) {
            ProgressView(value: progress, total: 30)
                .progressViewStyle(CustomCircularProgressViewStyle())
                .onReceive(timer) { time in
                    progress = 30 - Double(Calendar.current.component(.second, from: time) % 30)
                    
                    let seconds = Calendar.current.component(.second, from: time)
                    if (seconds == 0 || seconds == 30) {
                        accountData.updateCode(account: account)
                    }
                }

            GeometryReader { geo in
                HStack(alignment: .center) {
                    Spacer()
                    VStack(alignment: .center) {
                        Spacer()
                        VStack {
                            if (account.label != nil) {
                                Text("\(account.label!)")
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.1)
                            }

                            Text(account.formattedCode())
                                .lineLimit(1)
                                .font(.title2)
                                .minimumScaleFactor(0.1)

                            Text(account.issuer)
                                .lineLimit(1)
                                .minimumScaleFactor(0.1)

                            Text(account.user)
                                .lineLimit(1)
                                .font(.footnote)
                                .minimumScaleFactor(0.1)
                        }
                        .onAppear {
                            accountData.updateCode(account: account)
                        }
                        .frame(width: geo.size.width * 0.8, height: geo.size.height * 0.8)
                        Spacer()
                    }
                    Spacer()
                }
            }
        }
    }
}

struct AccountDetailView_Previews: PreviewProvider {
    static let accountData = AccountData()
    static let account = Account.example2

    static var previews: some View {
        AccountDetailView(account: account).environmentObject(accountData)
    }
}

struct CustomCircularProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        Circle()
            .trim(from: 0.0, to: CGFloat(configuration.fractionCompleted ?? 0))
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 3))
            .rotationEffect(.degrees(-90))
            .scaledToFill()
    }
}
