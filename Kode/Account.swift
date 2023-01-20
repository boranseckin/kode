//
//  Account.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-17.
//

import Foundation
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

struct Account: Codable, Identifiable {
    var id: UUID
    var type: Types = .TOTP
    var secret: String
    var issuer: String
    var algorithm: Algorithms = .SHA1
    var digits: Digits = .SIX
    var counter: Int?
    var label: String?
    var email: String
    var code: String = "000000"

    #if DEBUG
    static let example = Account(
        id: UUID(),
        secret: "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ",
        issuer: "Company A",
        label: "Test Account",
        email: "boran@boranseckin.com"
    )

    static let example2 = Account(
        id: UUID(),
        secret: "KUOEHG7ANDUFL4NAOIDN3BBV6LEVLT2N",
        issuer: "Company B",
        email: "boran@boranseckin.com"
    )
    #endif
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

class AccountData: ObservableObject {
    @Published var accounts = [Account]()

    init() {
        load()
        self.accounts.append(Account.example)
        self.accounts.append(Account.example2)
    }

    func add(account: Account) -> Bool {
        accounts.append(account)
        return save()
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
