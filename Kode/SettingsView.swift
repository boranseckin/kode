//
//  SettingsView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

#if !os(macOS)
import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accountData: AccountData

    @AppStorage("iCloudSync") private var icloud = false
    @AppStorage("WatchSync") private var watch = true

    @State private var checkStatus: Bool?
    @State private var showFullVersion: Bool = false

    var body: some View {
        List {
            Section {
                Toggle("Sync to iCloud", isOn: $icloud)
                    .onChange(of: icloud, perform: { value in
                        accountData.saveAll()
                        accountData.loadAll()
                    })
            } header: {
                Text("Sync")
            } footer: {
                Text("Enabling this option will sync your accounts across all sync enabled devices.")
            }
            
            if (Connectivity.standard.isAvailable()) {
                Section {
                    Toggle("Sync to Apple Watch", isOn: $watch)
                        .onChange(of: watch, perform: { value in
                            accountData.syncToWatch()
                        })
                } footer: {
                    Text("Enabling this option will allow you to access your accounts on your watch, even when it is not connected to your phone.")
                }
            }

            Section(header: Text("Info")) {
                HStack {
                    Text("Version")
                    Spacer()
                    if (showFullVersion) {
                        Text("\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))")
                    } else {
                        Text(Bundle.main.appVersionLong)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    showFullVersion.toggle()
                }

                NavigationLink("Acknowledgments") {
                    AcknowledgmentView()
                        .navigationTitle("Acknowledgments")
                }

                HStack(alignment: .center) {
                    Spacer()
                    Link(destination: URL(string: "https://boranseckin.com")!) {
                        HStack {
                            Image(systemName: "person.circle")
                            Text("Made by Boran Seckin")
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                    }
                    Spacer()
                }
            }
            
            #if DEBUG
            Section(header: Text("Debug")) {
                Button("Save", action: accountData.saveAll)

                Button("Load", action: accountData.loadAll)

                Button("Delete", action: accountData.deleteAll)

                HStack {
                    Button("Check", action: {
                        checkStatus = Data.checkFM(atPath: "account_ids")
                    })

                    Spacer()

                    if (checkStatus != nil && checkStatus!) {
                        Image(systemName: "checkmark.circle")
                            .foregroundColor(Color.green)
                    } else if (checkStatus != nil && !checkStatus!) {
                        Image(systemName: "x.circle")
                            .foregroundColor(Color.red)
                    }
                }
            }
            #endif
        }
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        SettingsView().environmentObject(accountData)
    }
}
#endif
