//
//  Account.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-17.
//

import Foundation
import SwiftOTP

struct Account: Codable, Identifiable {
    var id: UUID
    var secret: String
    var name: String
    var email: String
    var code: String
    
    #if DEBUG
    static let example = Account(
        id: UUID(),
        secret: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
        name: "Test Account",
        email: "boran@boranseckin.com",
        code: "000000"
    )
    
    static let example2 = Account(
        id: UUID(),
        secret: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
        name: "Test Account 2",
        email: "boran@boranseckin.com",
        code: "000000"
    )
    #endif
}

class AccountData: ObservableObject {
    @Published var accounts = [Account]()
    
    init() {
        load()
        self.accounts.append(Account.example)
        self.accounts.append(Account.example2)
    }
    
    func add(secret: String, name: String, email: String) {
        accounts.append(Account(id: UUID(), secret: secret, name: name, email: email, code: "000000"))
        _ = save()
    }
    
    func remove(at offset: IndexSet) {
        accounts.remove(atOffsets: offset)
        _ = save()
    }
    
    func move(source: IndexSet, destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        _ = save()
    }
    
    func updateCode(account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            if let data = base32DecodeToData(accounts[index].secret) {
                if let totp = TOTP(secret: data) {
                    accounts[index].code = totp.generate(time: Date())!
                }
            }
        }
    }
    
    func save() -> Bool {
        let json = Bundle.main.encode([Account].self, data: accounts)
        
        do {
            return try Data.saveFM(jsonObject: json, toFilename: "account_data")
        } catch {
            fatalError(error.localizedDescription)
        }
    }
    
    func load() {
        do {
            if let data = try Data.loadFM(withFilename: "account_data") {
                let json = Bundle.main.decode([Account].self, from: data)
                accounts = json
            }
        } catch {
            accounts = []
        }
    }
}
