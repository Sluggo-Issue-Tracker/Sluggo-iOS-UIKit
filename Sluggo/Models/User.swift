//
//  User.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct UserRecord: Codable {
    var id: Int
    var email: String
    var first_name: String?
    var last_name: String?
    var username: String

    static func createFromJSON(_ string: String) -> UserRecord? {
        // Get data
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for user object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let userRecord = try? decoder.decode(UserRecord.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for user object initialization.")
            return nil
        }
          return userRecord
      }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else {
                print("Failed to encode user object into JSON data.")
                return nil
                
            }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
