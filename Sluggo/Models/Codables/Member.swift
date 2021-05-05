//
//  Member.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

struct MemberRecord: Codable{
    var id: String
    var owner: UserRecord
    var team_id: Int
    var object_uuid: UUID
    var role: String
    @NullCodable var bio: String?
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?
}
