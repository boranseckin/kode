//
//  ContentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

import SwiftUI

#if os(iOS)
struct ContentView: View {
    @EnvironmentObject var accountData: AccountData

    @State private var progress = 30.0
    @State private var showAdd = false
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: IndexSet?
    @State private var editMode: EditMode = .inactive

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack {
                ProgressView(value: progress, total: 30)
                    .padding(.init(top: 1, leading: 15, bottom: 0, trailing: 15))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .onReceive(timer) { time in
                        progress = 30 - Double(Calendar.current.component(.second, from: time) % 30)
                    }

                List {
                    ForEach(accountData.accounts) { account in
                        if (editMode == .active) {
                            AccountEditRowView(account: account)
                        } else {
                            AccountRowView(account: account, progress: progress)
                                .moveDisabled(true)
                                .deleteDisabled(true)
                                .onReceive(timer) { time in
                                    let seconds = Calendar.current.component(.second, from: time)
                                    if (seconds == 0 || seconds == 30) {
                                        accountData.updateCode(account: account)
                                    }
                                }
                                .onAppear() {
                                    accountData.updateCode(account: account)
                                }
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
                                showDeleteAlert = false
                            },
                            secondaryButton: .cancel() {
                                toBeDeleted = nil
                                showDeleteAlert = false
                            }
                        )
                    })
                }
                .listSectionSpacing(0)
                .listStyle(.insetGrouped)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        EditButton()
                    }
                    
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button {
                            showAdd.toggle()
                        } label: {
                            Image(systemName: "plus")
                        }.sheet(isPresented: $showAdd, content: {
                            AccountAddView()
                        })
                        
                        NavigationLink(destination: SettingsView().navigationTitle("Settings")) {
                            Image(systemName: "gear")
                        }
                    }
                }
                .environment(\.editMode, $editMode)
                .navigationTitle("Kode")
                .navigationBarTitleDisplayMode(.inline)
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
#endif
