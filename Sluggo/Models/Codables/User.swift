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
    var full_name: String? {
        "\(first_name as String?) \(last_name as String?)"
    }
    var username: String
}
