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
            ContentView().environmentObject(accountData)
        }
    }
}
