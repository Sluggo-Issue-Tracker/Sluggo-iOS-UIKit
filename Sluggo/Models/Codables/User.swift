//
//  User.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation
import NullCodable

struct UserRecord: Codable {
    var id: Int
    var email: String
    @NullCodable var first_name: String?
    @NullCodable var last_name: String?
    var username: String
}

struct AuthRecord: Codable {
    var pk: Int
    var email: String
    @NullCodable var first_name: String?
    @NullCodable var last_name: String?
    var username: String
}
