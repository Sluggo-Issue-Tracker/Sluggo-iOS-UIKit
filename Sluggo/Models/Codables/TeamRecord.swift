//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
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

    func isMemberInTeam(memberRecord: MemberRecord?) -> Bool {
        guard let memberInfo = memberRecord else {
            return false
        }

        return self.id == memberInfo.team_id
    }
}
