//
//  Account.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-17.
//

import Foundation
import SwiftUI
import SwiftOTP

enum Types: Codable {
    case TOTP
    case HOTP
}

enum Algorithms: Codable {
    case SHA1
    case SHA256
    case SHA512
}

enum Digits: Codable {
    case SIX
    case EIGHT
}

// MARK: Account
struct Account: Codable, Identifiable {
    var id: UUID
    var type: Types = .TOTP
    var secret: String
    var issuer: String
    var algorithm: Algorithms = .SHA1
    var digits: Digits = .SIX
    var counter: Int?
    var email: String
    var label: String?
    var code: String = "000000"
    var order: Int = 999

    #if DEBUG
    static let example = Account(
        id: UUID(),
        secret: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
        issuer: "Company A",
        email: "boran@boranseckin.com",
        label: "Test Account"
    )

    static let example2 = Account(
        id: UUID(),
        secret: "KUOEHG7ANDUFL4NAOIDN3BBV6LEVLT2N",
        issuer: "Company B",
        email: "boran@boranseckin.com"
    )
    #endif
}

// MARK: Create Functions
func createAccount(
    type: Types = .TOTP,
    secret: String,
    issuer: String,
    algorithm: Algorithms = .SHA1,
    digits: Digits = .SIX,
    counter: Int? = nil,
    email: String,
    label: String?
) throws -> Account {
    guard let _ = base32DecodeToData(secret) else {
        throw "Invalid secret (cannot decode Base32)."
    }
    
    if (type == .HOTP && counter == nil) {
        throw "Invalid counter (counter is required for HOTP accounts)."
    }
    
    return Account(
        id: UUID(),
        type: type,
        secret: secret,
        issuer: issuer,
        algorithm: algorithm,
        digits: digits,
        counter: counter,
        email: email,
        label: (label != nil && !label!.isEmpty) ? label : nil
    )
}

func createAccountFromURIString(string: String) throws -> Account {
    if (!string.starts(with: "otpauth://totp")) {
        throw "Unknown or unsupported QR code."
    }
    
    guard let uri = URL(string: string) else {
        throw "Not a URI"
    }
    
    var secret = "", issuer = "", email = ""

    let main = substring(str: uri.path(percentEncoded: false), start: 1)
    if (main.contains(":")) {
        let components = main.components(separatedBy: ":")
        issuer = components[0]
        email = components[1]
    } else {
        email = main
    }

    let queryComponents = URLComponents(string: string)!.queryItems!
    for component in queryComponents {
        guard let value = component.value else { continue }

        switch component.name {
        case "secret":
            secret = value
        case "issuer":
            if (issuer.isEmpty) {
                issuer = value
            }
        default: break
        }
    }

    return Account(id: UUID(), secret: secret, issuer: issuer, email: email)
}

// MARK: AccountData
class AccountData: ObservableObject {
    @Published var accounts = [Account]()
    
    @AppStorage("WatchSync") private var watch = true
    
    var timerCounter = 0

    init() {
        #if !os(watchOS)
        loadAll()
        #if !os(macOS)
        syncToWatch()
        #endif

        Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            self.loadAll()
            #if !os(macOS)
            self.syncToWatch()
            #endif
        }
        #endif
    }

    func add(account: Account) {
        var newAccount = account
        newAccount.order = accounts.count
        accounts.append(newAccount)
        save(id: account.id)
    }

    func remove(at offset: IndexSet) {
        for index in offset {
            delete(id: accounts[index].id)
        }
        accounts.remove(atOffsets: offset)
    }

    func move(source: IndexSet, destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        saveAll()
    }
    
    func modify(account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
            save(id: account.id)
        }
    }

    func updateCode(account: Account) {
        #if !os(watchOS)
        let array = accounts
        #else
        let array = Connectivity.standard.accounts
        #endif

        if let index = array.firstIndex(where: { $0.id == account.id }) {
            if let data = base32DecodeToData(array[index].secret) {
                if let totp = TOTP(secret: data) {
                    #if !os(watchOS)
                    accounts[index].code = totp.generate(time: .now)!
                    #else
                    Connectivity.standard.accounts[index].code = totp.generate(time: .now)!
                    #endif
                } else {
                    print("UpdateCode: TOTP can not be created")
                }
            } else {
                print("UpdateCode: Secret decode not successfull")
            }
        } else {
            print("UpdateCode: Account not found")
            print(account)
        }
    }
    
    #if os(iOS)
    func syncToWatch() {
        var transfer = [[String: String]]()
        if (watch) {
            accounts.forEach { account in
                transfer.append(TransferrableAccount(account: account).toDict())
            }
        }

        Connectivity.standard.send(accounts: transfer, delivery: .highPriority)
        print("Synced")
    }
    #endif

    // MARK: SAVE
    func save(id: UUID) {
        do {
            if let index = accounts.firstIndex(where: { $0.id == id }) {
                let data = Bundle.main.encode(Account.self, data: accounts[index])
                try KeychainHelper.standard.save(value: data, account: id)
                print("Saved: \(id)")
            }
        } catch {
            fatalError("Failed to save keychain data: \(error)")
        }
    }
    
    func saveAll() {
        do {
            for (i, account) in accounts.enumerated() {
                var orderedAccount = account
                orderedAccount.order = i
                let data = Bundle.main.encode(Account.self, data: orderedAccount)
                try KeychainHelper.standard.save(value: data, account: orderedAccount.id)
                print("Saved (All): \(orderedAccount.id) - \(orderedAccount.order) (\(account.order))")
            }
        } catch {
            fatalError("Failed to save all keychain data: \(error)")
        }
    }
    
    
    // MARK: LOAD
    func load(id: UUID) {
        do {
            let fetchedAccount = try KeychainHelper.standard.get(account: id)

            accounts = []
            let account = Bundle.main.decode(Account.self, from: fetchedAccount)
            updateCode(account: account)

            let index = accounts.firstIndex(where: { $0.id == account.id })
            if index == nil {
                print("Loaded: \(account.id) - \(account.order)")
                accounts.append(account)
            } else {
                accounts[index!] = account
            }
            accounts.sort(by: { $0.order < $1.order })
        } catch {
            fatalError("Failed to retrieve keychain data: \(error)")
        }
    }
    
    func loadAll() {
        do {
            let fetchedAccounts = try KeychainHelper.standard.getAll()

            accounts = []
            for fetchedAccount in fetchedAccounts {
                let account = Bundle.main.decode(Account.self, from: fetchedAccount)
                if !accounts.contains(where: { $0.id == account.id }) {
                    print("Loaded: \(account.id) - \(account.order)")
                    accounts.append(account)
                    updateCode(account: account)
                }
            }
            accounts.sort(by: { $0.order < $1.order })
        } catch {
            fatalError("Failed to retrieve keychain data: \(error)")
        }
    }
    
    // MARK: DELETE
    func delete(id: UUID) {
        do {
            try KeychainHelper.standard.delete(account: id)
            print("Deleted: \(id)")
        } catch {
            fatalError("Failed to delete keychain data: \(error)")
        }
    }
    
    func deleteAll() {
        do {
            try KeychainHelper.standard.deleteAll()
            accounts = []
            print("Deleted all!")
        } catch {
            fatalError("Failed to delete all keychain data: \(error)")
        }
    }
}
