//
//  ContentView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

#if !os(macOS)
import SwiftUI
import LocalAuthentication

struct ContentView: View {
    @EnvironmentObject var accountData: AccountData
    @Environment(\.scenePhase) var scenePhase

    @State private var progress = 30.0
    @State private var showAdd = false
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: IndexSet?
    @State private var editMode: EditMode = .inactive
    
    @State private var isUnlocked = true
    @State private var debounceAuth = false
    @AppStorage("BioAuth") private var bio = false

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if bio && !isUnlocked {
                VStack {
                    Spacer()

                    Image("Icon")
                        .resizable()
                        .frame(width: 200, height: 200)
                        .cornerRadius(20)
                    
                    Spacer()
                    
                    Button("Unlock", action: authenticate)
                        .padding()
                        .background(.blue)
                        .foregroundStyle(.white)
                        .clipShape(.capsule)
                    
                    Spacer()
                }
            } else {
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
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if bio {
                if newPhase == .active {
                    if !debounceAuth {
                        debounceAuth = true
                        authenticate()
                    } else {
                        debounceAuth = false
                    }
                } else if newPhase == .inactive {
                    isUnlocked = false
                } else if newPhase == .background {
                    isUnlocked = false
                }
            }
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "Required to unlock the app."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                isUnlocked = success
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
