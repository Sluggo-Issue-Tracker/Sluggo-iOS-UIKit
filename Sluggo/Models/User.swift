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
    
    init(id: Int, email: String, first_name: String?, last_name: String?, username: String) {
        self.id = id
        self.email = email
        self.first_name = first_name
        self.last_name = last_name
        self.username = username
    }
    
    init?(fromJSONString: String) { // Initializer for data from JSON
        // Get data
        guard let jsonData = fromJSONString.data(using: .utf8) else { return nil }
        
        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let userRecord = try? decoder.decode(UserRecord.self, from: jsonData) else { return nil }
        
        // Initialize using standard initializer
        self.init(id: userRecord.id, email: userRecord.email, first_name: userRecord.first_name, last_name: userRecord.last_name, username: userRecord.username)
    }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else { return nil }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
