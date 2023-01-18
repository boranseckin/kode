//
//  Utils.swift
//  Kode
//
//  Created by Boran Seckin on 2023-01-18.
//

import Foundation

// https://stackoverflow.com/a/40629365/10161292
extension String: Error {}

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
}

extension Data {
    // https://gist.github.com/norsez/aa3f11c0e875526e5270e7791f3891fb
    static func saveFM(jsonObject: Data, toFilename filename: String) throws -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)

        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")

            try jsonObject.write(to: fileURL, options: [.atomicWrite])
            return true
        }

        return false
    }
    
    static func loadFM(withFilename filename: String) throws -> Data? {
        if !checkFM(atPath: filename) {
            throw "File does not exist at \(filename)"
        }
        
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)

        if let url = urls.first {
            var fileURL = url.appendingPathComponent(filename)
            fileURL = fileURL.appendingPathExtension("json")

            let data = try Data(contentsOf: fileURL)
            return data
        }

        return nil
    }
    
    static func deleteFM(atPath path: String) throws {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)

        if let url = urls.first {
            var fileURL = url.appendingPathComponent(path)
            fileURL = fileURL.appendingPathExtension("json")

            try fm.removeItem(atPath: fileURL.path)
        }
    }
    
    static func checkFM(atPath path: String) -> Bool {
        let fm = FileManager.default
        let urls = fm.urls(for: .documentDirectory, in: .userDomainMask)

        if let url = urls.first {
            var fileURL = url.appendingPathComponent(path)
            fileURL = fileURL.appendingPathExtension("json")

            return fm.fileExists(atPath: fileURL.path)
        }

        return false
    }
}
