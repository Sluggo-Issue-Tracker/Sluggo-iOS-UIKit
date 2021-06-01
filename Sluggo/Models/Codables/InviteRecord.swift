//
//  InviteRecord.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/31/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct UserInviteRecord: Codable {
    var id: Int
    var team: TeamRecord
}

struct TeamInviteRecord: Codable {
    var id: Int
    var email: String
    var team: TeamRecord
}
