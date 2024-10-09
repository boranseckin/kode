//
//  ListView.swift
//  Kode
//
//  Created by Boran Seckin on 2024-10-04.
//

#if !os(macOS)
import SwiftUI

struct ListView: View {
    @EnvironmentObject var accountData: AccountData

    @State private var isShowingDetailView = false
    @State private var showDeleteAlert = false
    @State private var toBeDeleted: Account? = nil
    @State private var editMode: EditMode = .inactive
    
    @Binding var synced: Bool

    var body: some View {
        List {
            ForEach(accountData.accounts, id: \.id) { account in
                if (editMode == .active) {
                    AccountEditRowView(account: account)
                } else {
                    AccountRowView(account: account)
                        .padding(.vertical, 4)
                        .onChange(of: synced, { oldValue, newValue in
                            accountData.updateCode(account: account)
                        })
                        .onAppear() {
                            accountData.updateCode(account: account)
                        }
                        .swipeActions {
                            Button("Remove") {
                                toBeDeleted = account
                                showDeleteAlert = true
                            }
                            .tint(.red)
                        }
                }
            }
            .onMove(perform: accountData.move)
            .confirmationDialog("Are you sure you want to remove this account? (This action cannot be undone.)", isPresented: $showDeleteAlert, titleVisibility: .visible) {
                Button("Remove", role: .destructive) {
                    withAnimation {
                        deleteItem(toBeDeleted)
                    }
                }
            }
        }
        .contentMargins(.top, 12, for: .scrollContent)
        .listSectionSpacing(0)
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .environment(\.editMode, $editMode)
    }
    
    func deleteItem(_ item: Account?) {
        guard let item else { return }
        accountData.remove(account: item)
        toBeDeleted = nil
    }
}

#Preview {
    ListView(synced: .constant(true))
}
#endif
