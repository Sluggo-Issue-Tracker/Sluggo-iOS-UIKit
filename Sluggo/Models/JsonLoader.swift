//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader {
    static func decode<T: Codable>(_ string: String) -> T? {
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let pagRec = try? decoder.decode(T.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for object initialization.")
            return nil
        }

        return pagRec
    }
    
    static func encode<T: Codable>(_ data: T) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        // Attempt encoding
        guard let jsonData = try? encoder.encode(data) else {
            print("Failed to encode object into JSON data.")
            return nil
            
        }
        
        // Attempt stringifying the data, this is failable, which is fine since property is optional.
        return String(data: jsonData, encoding: .utf8)
    }
}
