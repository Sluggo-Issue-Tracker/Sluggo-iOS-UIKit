//
//  TicketRecord.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//  Edited by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable

struct TicketRecord: Codable {
    var id: Int
    var ticket_number: Int
    var tag_list: [TagRecord]
    var object_uuid: UUID
    @NullCodable var assigned_user: MemberRecord?
    @NullCodable var status: StatusRecord?
    var title: String
    @NullCodable var description: String?
    // var comments?  Future Future Implementation
    @NullCodable var due_date: Date?
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?
    
    
}

struct WriteTicketRecord: Codable{
    var tag_list: [Int]
    @NullCodable var assigned_user: String?
    @NullCodable var status: Int?
    var title: String
    @NullCodable var description: String?
    @NullCodable var due_date: Date?
}
