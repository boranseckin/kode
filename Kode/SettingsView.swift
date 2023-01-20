//
//  SettingsView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accountData: AccountData

    @Environment(\.openURL) var openURL
    
    @AppStorage("iCloudSync") private var icloud = false
    
    @State private var checkStatus: Bool?

    var body: some View {
        List {
            Section {
                Toggle("iCloud Sync", isOn: $icloud)
            }
            
            Section(header: Text("Debug")) {
                Button("Save", action: {
                    if !accountData.save() {
                        fatalError("Failed to save")
                    }
                })

                Button("Load", action: {
                    accountData.load()
                })

                Button("Delete", action: {
                    do {
                        try Data.deleteFM(atPath: "account_data")
                    } catch {
                        print(error.localizedDescription)
                    }
                })

                HStack {
                    Button("Check", action: {
                        checkStatus = Data.checkFM(atPath: "account_data")
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
            
            Section(header: Text("Info")) {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))")
                }
                
                NavigationLink("Acknowledgment") {
                    AcknowledgmentView()
                        .navigationTitle("Acknowledgment")
                }

                HStack {
                    Spacer()
                    Image(systemName: "person.circle")
                    Text("Made by Boran Seckin")
                        .font(.subheadline)
                    Spacer()
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    openURL(URL(string: "https://boranseckin.com")!)
                }
            }
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
