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
        self.accounts.append(Account.example)
        self.accounts.append(Account.example2)
    }
    
    func add(secret: String, name: String, email: String) {
        accounts.append(Account(id: UUID(), secret: secret, name: name, email: email, code: "000000"))
    }
    
    func remove(at offset: IndexSet) {
        accounts.remove(atOffsets: offset)
    }
    
    func move(source: IndexSet, destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
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
}
