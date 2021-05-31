//
//  InviteRecord.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/31/21.
//

import Foundation
import NullCodable

// swiftlint:disable identifier_name
struct InviteRecord: Codable {
    var id: Int
    var team: TeamRecord
}
