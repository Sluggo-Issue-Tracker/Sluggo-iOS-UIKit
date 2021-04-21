//
//  JsonLoader.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/19/21.
//

import Foundation

class JsonLoader {
    static func decode<T: Codable>(_ data: Data) -> T? {
        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let pagRec = try? decoder.decode(T.self, from: data) else {
            print("Failed to decode JSON data into object representation for object initialization.")
            return nil
        }

        return pagRec
    }
    
    static func encode<T: Codable>(_ data: T) -> Data? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        
        // Attempt encoding
        guard let jsonData = try? encoder.encode(data) else {
            print("Failed to encode object into JSON data.")
            return nil
            
        }
        
        // Attempt stringifying the data, this is failable, which is fine since property is optional.
        return jsonData
    }
}
