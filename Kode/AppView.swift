//
//  AppView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

struct AppView: View {
    @State private var tabSelection = 1
    
    var body: some View {
        TabView(selection: $tabSelection) {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Accounts")
                }
                .tag(1)
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(2)
        }
    }
}

struct AppView_Previews: PreviewProvider {
    static let accountData = AccountData()
    
    static var previews: some View {
        AppView().environmentObject(accountData)
    }
}
