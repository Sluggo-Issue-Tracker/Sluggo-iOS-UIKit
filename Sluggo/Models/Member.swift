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
}
