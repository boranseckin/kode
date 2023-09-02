//
//  KeychainHelper.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-23.
//

import Foundation
import SwiftUI

final class KeychainHelper {
    static let standard = KeychainHelper()
    
    @AppStorage("iCloudSync") private var icloud = false
    
    // MARK: SAVE
    func save(value: Data, account: UUID) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: icloud,
            kSecAttrLabel: "KodeAccount".data(using: .utf8)!,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            kSecValueData: value
        ] as [CFString : Any] as CFDictionary

        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery = [
                kSecClass: kSecClassGenericPassword,
                kSecUseDataProtectionKeychain: true,
                kSecAttrSynchronizable: icloud,
                kSecAttrLabel: "KodeAccount".data(using: .utf8)!,
                kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            ] as [CFString : Any] as CFDictionary
            let updateData = [kSecValueData: value] as CFDictionary
            
            let updateStatus = SecItemUpdate(updateQuery, updateData)
            guard updateStatus == errSecSuccess else {
                throw "Unable to update data on the keychain. (\(status))"
            }
            
            return
        }
        
        guard status == errSecSuccess else {
            throw "Unable to save data to the keychain. (\(status))"
        }
    }
    
    // MARK: GET
    func get(account: UUID) throws -> Data {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: icloud,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            kSecReturnData: true
        ] as [CFString : Any] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        guard status == errSecSuccess else {
            throw "Unable to retrieve data from the keychain. (\(status))"
        }
        
        return result as! Data
    }
    
    // MARK: GET ALL
    func getAll() throws -> [Data] {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: icloud,
            kSecAttrLabel: "KodeAccount".data(using: .utf8)!,
            kSecMatchLimit: kSecMatchLimitAll,
            kSecReturnData: true
        ] as [CFString : Any] as [CFString : Any] as CFDictionary

        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecItemNotFound {
            return Array<Data>()
        }

        guard status == errSecSuccess else {
            throw "Unable to retrieve all data from the keychain. (\(status))"
        }

        return result as! CFArray as! Array<Data>
    }
    
    // MARK: DELETE
    func delete(account: UUID) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: icloud,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!
        ] as [CFString : Any] as CFDictionary
        
        let status = SecItemDelete(query)
        guard status == errSecSuccess else {
            throw "Unable to delete data from the keychain. (\(status))"
        }
    }
    
    // MARK: DELETE ALL
    func deleteAll() throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecUseDataProtectionKeychain: true,
            kSecAttrSynchronizable: icloud,
            kSecAttrLabel: "KodeAccount".data(using: .utf8)!
        ] as [CFString : Any] as CFDictionary
        
        let status = SecItemDelete(query)
        
        guard status == errSecSuccess else {
            if status == errSecItemNotFound {
                return
            }
            throw "Unable to delete all data from the keychain. (\(status))"
        }
    }
}
