//
//  ContentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

import SwiftUI
import Base32

struct ContentView: View {
    @EnvironmentObject var accountData: AccountData

    @State private var progress = 30.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            List {
                ForEach(accountData.accounts) { account in
                    AccountRowView(account: account, progress: progress)
                        .onReceive(timer) { time in
                            progress = 30 - Double(Calendar.current.component(.second, from: time) % 30)

                            let seconds = Calendar.current.component(.second, from: time)
                            if (seconds == 0 || seconds == 30) {
                                accountData.updateCode(account: account)
                            }
                        }
                        .onAppear() {
                            accountData.updateCode(account: account)
                        }
                }
                .onDelete(perform: accountData.remove)
            }
            .navigationTitle("Kode")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddAccountView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        ContentView().environmentObject(accountData)
    }
}
