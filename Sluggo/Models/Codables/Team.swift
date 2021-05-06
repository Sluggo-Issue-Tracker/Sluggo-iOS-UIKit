//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

struct TeamRecord: Codable, Equatable {
    var id: Int
    var name: String
    var object_uuid: UUID
    var ticket_head: Int
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?
    
    static func == (lhs: TeamRecord, rhs: TeamRecord) -> Bool {
        return lhs.object_uuid == rhs.object_uuid
    }
}
