//
//  User.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct UserRecord: Codable {
    var id: Int
    var email: String
    var first_name: String?
    var last_name: String?
    var username: String
}
