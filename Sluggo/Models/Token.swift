//
//  Token.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/15/21.
//

import Foundation


struct TokenRecord: Codable {
    var key: String
    
    static func createFromJSON(_ string: String) -> TokenRecord? {
        // Get data
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for Token object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let tokenRec = try? decoder.decode(TokenRecord.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for Token object initialization.")
            return nil
        }
          return tokenRec
      }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else {
                print("Failed to encode Token object into JSON data.")
                return nil
                
            }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
