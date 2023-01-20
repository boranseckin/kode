//
//  ContentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountData: AccountData

    @State private var progress = 30.0
    @State private var showAdd = false
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: IndexSet?

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
                .onMove(perform: accountData.move)
                .onDelete(perform: { index in
                    toBeDeleted = index
                    showDeleteAlert.toggle()
                })
                .alert(isPresented: $showDeleteAlert, content: {
                    Alert(
                        title: Text("Are you sure you want to delete this account?"),
                        message: Text("This action is irreversable!"),
                        primaryButton: .destructive(Text("Yes")) {
                            accountData.remove(at: toBeDeleted!)
                            toBeDeleted = nil
                        },
                        secondaryButton: .cancel() {
                            toBeDeleted = nil
                        }
                    )
                })
            }
            .navigationTitle(Text("Kode"))
            #if os(iOS)
            .listStyle(.insetGrouped)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showAdd.toggle()
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2)
                    }.sheet(isPresented: $showAdd, content: {
                        AddAccountView()
                    })

                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gear")
                    }
                }
            }
            #endif
        }
        .navigationViewStyle(.stack)
    }
}

struct ContentView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        ContentView().environmentObject(accountData)
    }
}
