//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct TeamRecord: Codable, Equatable {
    var id: Int
    var name: String
    var object_uuid: UUID
    var ticket_head: Int
    var created: Date
    var activated: Date?
    var deactivated: Date?
    
    static func == (lhs: TeamRecord, rhs: TeamRecord) -> Bool {
        return lhs.id == rhs.id &&
            lhs.object_uuid == rhs.object_uuid &&
            lhs.ticket_head == rhs.ticket_head &&
            lhs.created == rhs.created &&
            lhs.activated == rhs.activated &&
            lhs.deactivated == rhs.deactivated
    }
}
