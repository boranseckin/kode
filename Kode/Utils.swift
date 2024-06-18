//
//  Utils.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import Foundation

// https://stackoverflow.com/a/40629365/10161292
extension String: Error {}

func substring(str: String, start: Int? = nil, end: Int? = nil) -> String {
    let data = Array(str)
    return String(data[(start != nil ? start! : 0)..<(end != nil ? end! : str.count)])
}

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode \(data)")
        }

        return decoded
    }

    func encode<T: Encodable>(_ type: T.Type, data: T) -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        guard let encoded = try? encoder.encode(data) else {
            fatalError("Failed to encode \(data)")
        }

        return encoded
    }

    public var appBuild: String         { getInfo("CFBundleVersion") }
    public var appVersionLong: String   { getInfo("CFBundleShortVersionString") }
    public var appVersionShort: String  { getInfo("CFBundleShortVersion") }
    
    fileprivate func getInfo(_ str: String) -> String { infoDictionary?[str] as? String ?? "" }
}
