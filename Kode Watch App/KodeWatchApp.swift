//
//  KodeApp.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-16.
//

import SwiftUI

@main
struct KodeWatchApp: App {
    var body: some Scene {
        let accountData = AccountData()
        
        WindowGroup {
            ContentViewWatch().environmentObject(accountData)
        }
    }
}
