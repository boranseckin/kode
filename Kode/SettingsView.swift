//
//  SettingsView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var accountData: AccountData
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Debug")) {
//                    Button("Print", action: {
//                        accountData.printc()
//                    })
                    
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
                    
                    Button("Check", action: {
                        let path = Data.checkFM(atPath: "account_data")
                        print(path)
                    })
                }
            }
            .navigationTitle("Settings")
            .listStyle(InsetGroupedListStyle())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let accountData = AccountData()
    
    static var previews: some View {
        SettingsView().environmentObject(accountData)
    }
}
