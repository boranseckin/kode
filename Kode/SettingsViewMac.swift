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

    @State private var showFullVersion: Bool = false
    
    var SettingsTab: some View {
        Toggle("iCloud Sync", isOn: $icloud)
            .onChange(of: icloud, perform: { value in
                accountData.saveAll()
                accountData.loadAll()
            })
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
                
                Text("Kode App")
                    .font(.title3)
                
                HStack {
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
            SettingsTab
                .tabItem {
                    Label("Settings", systemImage: "gear")
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
