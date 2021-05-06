//
//  PinnedTicket.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/5/21.
//

import Foundation

struct PinnedTicketRecord: Codable {
    let id: String // Primary key
    let object_uuid: String
    let pinned: Date
    let ticket: TicketRecord
}

struct WritePinnedTicketRecord: Codable {
    let ticketID: Int
}
