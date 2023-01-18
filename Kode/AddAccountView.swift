//
//  AddAccountView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import SwiftUI

struct AddAccountView: View {
    @EnvironmentObject var accountData: AccountData

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct AddAccountView_Previews: PreviewProvider {
    static let accountData = AccountData()
    
    static var previews: some View {
        AddAccountView().environmentObject(accountData)
    }
}
