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
            #if os(iOS)
            ContentView().environmentObject(accountData)
            #else
            ContentViewMac().environmentObject(accountData)
                .frame(width: 300)
            #endif
        }
        #if os(macOS)
        .windowResizability(.contentSize)
        #endif
        
        #if os(macOS)
        Settings {
            NavigationStack {
                SettingsViewMac()
                    .frame(width: 300)
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
