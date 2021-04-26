//
//  TicketRecord.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//  Edited by Stephan Martin on 4/25/21.
//

import Foundation

struct TicketRecord: Codable {
    var id: Int
    var ticket_number: Int
    var taglist: [TagRecord]?
    var object_uuid: UUID
    var status: StatusRecord?
    var assigned_user: UserRecord?
    var title: String
    var description: String?
    // var comments?  Future Future Implementation
    var created: Date
    var activated: Date?
    var deactivated: Date?
    
    
}
