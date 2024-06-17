//
//  KodeApp.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

import SwiftUI

@main
struct KodeApp: App {
    var body: some Scene {
        let accountData = AccountData()
        
        WindowGroup {
            #if !os(macOS)
            ContentView().environmentObject(accountData)
            #else
            ContentViewMac().environmentObject(accountData)
                .frame(minWidth: 300, maxWidth: 300, minHeight: 100)
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
        
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsViewMac()
                    .environmentObject(accountData)
            }
        }
        
        Window("Acknowledgments", id: "acknowledgments") {
            AcknowledgmentView()
                .frame(width: 300, height: 300)
        }
        .windowResizability(.contentSize)
        #endif
    }
}
