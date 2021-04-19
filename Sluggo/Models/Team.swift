//
//  Team.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/14/21.
//

import Foundation


struct TeamRecord: Codable {
    var id: Int
    var name: String
    var object_uuid: UUID
    var ticket_head: Int
    var created: Date
    var activated: Date?
    var deactivated: Date?
   
}
