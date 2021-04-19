//
//  PaginatedList.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/18/21.
//

import Foundation

struct PaginatedList<T : Codable> : Codable {
    var count: Int
    var next: String?
    var previous: String?
    let results: [T]
    
    static func createFromJSON(_ string: String) -> PaginatedList<T>? {
        // Get data
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for PaginatedList object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let pagRec = try? decoder.decode(PaginatedList<T>.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for PaginatedList object initialization.")
            return nil
        }
          return pagRec
      }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else {
                print("Failed to encode PaginatedList object into JSON data.")
                return nil
                
            }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
