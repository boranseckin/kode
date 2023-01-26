//
//  KeychainHelper.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-23.
//

import Foundation

final class KeychainHelper {
    static let standard = KeychainHelper()
    
    func save(value: Data, account: UUID) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            kSecValueData: value
        ] as CFDictionary
        
        let status = SecItemAdd(query, nil)
        
        if status == errSecDuplicateItem {
            let updateQuery = [
                kSecClass: kSecClassGenericPassword,
                kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            ] as CFDictionary
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
    
    func get(account: UUID) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        
        if status == errSecSuccess {
            if let data = result as? Data {
                return String(data: data, encoding: .utf8)
            }
        }
        
        return nil
    }
    
    func delete(account: UUID) throws {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: account.uuidString.data(using: .utf8)!
        ] as CFDictionary
        
        let status = SecItemDelete(query)
        guard status == errSecSuccess else {
            throw "Unable to delete data from the keychain."
        }
    }
}
