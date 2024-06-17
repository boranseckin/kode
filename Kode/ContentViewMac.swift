//
//  ContentViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-20.
//

#if os(macOS)
import SwiftUI

struct ContentViewMac: View {
    @EnvironmentObject var accountData: AccountData
    
    @AppStorage("alwaysOnTop") private var alwaysOnTop = true

    @State private var progress = 30.0
    @State private var showAdd = false
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: IndexSet?

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        List {
            ForEach(accountData.accounts) { account in
                AccountRowViewMac(account: account, progress: progress)
                    .onReceive(timer) { time in
                        progress = 30 - Double(Calendar.current.component(.second, from: time) % 30)
                        
                        let seconds = Calendar.current.component(.second, from: time)
                        if (seconds == 0 || seconds == 30) {
                            accountData.updateCode(account: account)
                        }
                    }
                    .onAppear() {
                        accountData.updateCode(account: account)
                        #if os(macOS)
                        updateWindowLevel(level: alwaysOnTop ? .floating : .normal)
                        #endif
                    }
            }
        }
        .navigationTitle("Kode")
        .toolbar {
            ToolbarItem {
                Button {
                    showAdd.toggle()
                } label: {
                    Image(systemName: "plus")
                        .font(.title2)
                }.sheet(isPresented: $showAdd, content: {
                    AccountAddView()
                })
            }
        }
    }
}

struct ContentViewMac_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        ContentViewMac().environmentObject(accountData)
    }
}
#endif
