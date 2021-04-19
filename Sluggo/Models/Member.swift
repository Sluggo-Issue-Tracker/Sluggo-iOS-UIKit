//
//  Member.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct MemberRecord: Codable {
    var id: String
    var owner: UserRecord
    var team_id: Int
    var object_uuid: UUID
    var role: String
    var bio: String?
    var created: Date
    var activated: Date?
    var deactivated: Date?

    static func createFromJSON(_ string: String) -> MemberRecord? {
        // Get data
        guard let jsonData = string.data(using: .utf8) else {
            print("Failed to decode provided JSON string into data for Member object intialization.")
            return nil
        }

        // Attempt decoding
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        guard let memberRecord = try? decoder.decode(MemberRecord.self, from: jsonData) else {
            print("Failed to decode JSON data into object representation for Member object initialization.")
            return nil
        }
          return memberRecord
      }
    
    var jsonString: String? {
        get {
            // obtain an encoder
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = .prettyPrinted
            
            // Attempt encoding
            guard let jsonData = try? encoder.encode(self) else {
                print("Failed to encode Member object into JSON data.")
                return nil
                
            }
            
            // Attempt stringifying the data, this is failable, which is fine since property is optional.
            return String(data: jsonData, encoding: .utf8)
        }
    }
}
