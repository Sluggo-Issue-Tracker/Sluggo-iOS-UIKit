//
//  PinnedTicket.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/5/21.
//

import Foundation

struct PinnedTicket: Codable {
    let id: String // Primary key
    let object_uuid: String
    let pinned: Date
    let ticket: TicketRecord
}
