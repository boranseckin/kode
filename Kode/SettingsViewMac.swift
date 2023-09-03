//
//  SettingsViewMac.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

#if os(macOS)
public func updateWindowLevel(level: NSWindow.Level) {
    for window in NSApplication.shared.windows {
        window.level = level
    }
}
#endif

struct SettingsViewMac: View {
    @EnvironmentObject var accountData: AccountData
    
    @Environment(\.openWindow) var openWindow
    
    @AppStorage("iCloudSync") private var icloud = false
    @AppStorage("alwaysOnTop") private var alwaysOnTop = false
    
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
    
    var SettingsTab: some View {
        VStack {
            Toggle("Always on Top", isOn: $alwaysOnTop)
                .onChange(of: alwaysOnTop, perform: { value in
                    #if os(macOS)
                    updateWindowLevel(level: value ? .floating : .normal)
                    #endif
                })
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
            
            SettingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
            
            AboutTab
                .tabItem {
                    Label("About", systemImage: "info")
                }
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
