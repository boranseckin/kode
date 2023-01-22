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

    init() {
        load()
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
    
    func modify(account: Account) -> Bool {
        if let i = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[i] = account
            return save()
        }
        
        return false
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
