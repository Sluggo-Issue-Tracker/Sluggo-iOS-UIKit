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
    var tag_list: [TagRecord]?
    var object_uuid: UUID
    var assigned_user: MemberRecord?
    var status: StatusRecord?
    var title: String
    var description: String?
    // var comments?  Future Future Implementation
    var due_date: Date?
    var created: Date
    var activated: Date?
    var deactivated: Date?
    
    
}
