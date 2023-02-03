//
//  SettingsViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct SettingsViewMac: View {
    @EnvironmentObject var accountData: AccountData
    
    @Environment(\.openWindow) var openWindow
    
    @AppStorage("iCloudSync") private var icloud = false
    
    var AccountsTab: some View {
        VStack {
            List {
                ForEach(accountData.accounts) { account in
                    AccountEditRowView(account: account)
                }
                .onMove(perform: accountData.move)
            }
            .listStyle(.inset)
            .frame(minHeight: 300)
            
            Text("Click and drag to reorder the list.")
                .font(.caption)
        }
    }
    
    var SyncTab: some View {
        VStack {
            Toggle("iCloud Sync", isOn: $icloud)
                .onChange(of: icloud, perform: { value in
                    accountData.saveAll()
                    accountData.loadAll()
                })
            
            Text("Enabling this option will sync your accounts\nacross all sync enabled devices.")
                .font(.caption)
                .multilineTextAlignment(.center)
        }
        .frame(height: 50)
    }
    
    var DebugTab: some View {
        VStack {
            Button("Save", action: accountData.saveAll)
            
            Button("Load", action: accountData.loadAll)
            
            Button("Delete", action: accountData.deleteAll)
        }
    }
    
    var AboutTab: some View {
        VStack(spacing: 20) {
            VStack(spacing: 5) {
                Image("Icon")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .cornerRadius(20)
                
                Text("Kode App")
                    .font(.title3)

                Text("\(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))")
            }

            Button("Acknowledgments") {
                openWindow(id: "acknowledgments")
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
    }

    var body: some View {
        TabView {
            AccountsTab
                .tabItem {
                    Label("Accounts", systemImage: "person")
                }
            
            SyncTab
                .tabItem {
                    Label("Sync", systemImage: "icloud")
                }
            
            AboutTab
                .tabItem {
                    Label("About", systemImage: "info")
                }
            
            #if DEBUG
            DebugTab
                .tabItem {
                    Label("Debug", systemImage: "wrench.and.screwdriver")
                }
            #endif
        }
        .padding()
    }
}

struct SettingsViewMac_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        SettingsViewMac().environmentObject(accountData)
    }
}
