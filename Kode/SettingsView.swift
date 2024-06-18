//
//  SettingsView.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

#if !os(macOS)
import SwiftUI
import LocalAuthentication

struct SettingsView: View {
    @EnvironmentObject var accountData: AccountData

    @AppStorage("iCloudSync") private var icloud = false
    @AppStorage("WatchSync") private var watch = true
    @AppStorage("BioAuth") private var bio = false

    @State private var showFullVersion: Bool = false
    @State private var isAuthAvailable: Bool = false

    var body: some View {
        List {
            Section {
                Toggle("Sync to iCloud", isOn: $icloud)
                    .onChange(of: icloud, {
                        accountData.saveAll()
                        accountData.loadAll()
                    })
            } header: {
                Text("Sync")
            } footer: {
                Text("Enabling this option will sync your accounts across all sync enabled devices.")
            }
            
            if (Connectivity.standard.isAvailable()) {
                Section {
                    Toggle("Sync to Apple Watch", isOn: $watch)
                        .onChange(of: watch, {
                            accountData.syncToWatch()
                        })
                } footer: {
                    Text("Enabling this option will allow you to access your accounts on your watch, even when it is not connected to your phone.")
                }
            }
            
            Section {
                Toggle("Enable \(getAuthName())", isOn: $bio)
            } header: {
                Text("Security")
            } footer: {
                if isAuthAvailable {
                    Text("Enabling this option will require device owner authentication upon launching the app.")
                } else {
                    Text("Device owner authentication is not available on this device.")
                }
            }
            .disabled(!isAuthAvailable)

            Section(header: Text("Info")) {
                HStack {
                    Text("Version")
                    Spacer()
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

                NavigationLink("Acknowledgments") {
                    AcknowledgmentView()
                        .navigationTitle("Acknowledgments")
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
        #if os(iOS)
        .listStyle(.insetGrouped)
        #endif
        .onAppear {
            isAuthAvailable = isAuthenticatable()
        }
    }
    
    func getAuthName() -> String {
        let context = LAContext()
        switch context.biometryType {
            case .faceID: return "Face ID"
            case .touchID: return "Touch ID"
            case .opticID: return "Optic ID"
            case .none: return "Passcode"
            @unknown default: return "Authentication"
        }
    }

    func isAuthenticatable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static let accountData = AccountData()

    static var previews: some View {
        SettingsView().environmentObject(accountData)
    }
}
#endif
