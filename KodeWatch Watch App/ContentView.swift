//
//  ContentView.swift
//  KodeWatch Watch App
//
//  Created by Boran Seckin on 2023-01-28.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var accountData: AccountData
    @ObservedObject var connectivity = Connectivity.standard

    var body: some View {
        NavigationView {
            VStack {
                if (connectivity.accounts.count == 0) {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    List {
                        ForEach(connectivity.accounts) { account in
                            NavigationLink {
                                AccountDetailView(account: account)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(account.issuer)
                                    Text(account.email)
                                        .font(.footnote)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Kode")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
