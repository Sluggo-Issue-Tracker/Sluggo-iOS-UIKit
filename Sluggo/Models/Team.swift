//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct TeamRecord: Codable {
    var id: Int
    var name: String
    var object_uuid: UUID
    var ticket_head: Int
    var created: Date
    var activated: Date?
    var deactivated: Date?
   
    static func createFromJSON(_ string: String) -> TeamRecord? {
        // Get data
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for Team object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let teamRec = try? decoder.decode(TeamRecord.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for Team object initialization.")
            return nil
        }
          return teamRec
      }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else {
                print("Failed to encode Team object into JSON data.")
                return nil
                
            }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
    
}
