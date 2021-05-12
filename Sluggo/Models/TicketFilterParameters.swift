//
//  FilterParameters.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/12/21.
//

import Foundation

struct TicketFilterParameters {
    var assignedUser: MemberRecord? = nil
    var ticketTag: TagRecord? = nil
    var ticketStatus: StatusRecord? = nil
    
    init(assignedUser: MemberRecord? = nil, ticketTag: TagRecord? = nil, ticketStatus: StatusRecord? = nil) {
        self.assignedUser = assignedUser
        self.ticketTag = ticketTag
        self.ticketStatus = ticketStatus
    }
    
    // does not include the initial ? so that it may work with pagination
    func toParamString() -> String {
        var paramString = ""
        
        if let member = assignedUser {
            paramString += "&assigned_user__owner__username=\(member.owner.username)"
        }
        
        if let tag = ticketTag {
            paramString += "&tag_list__title=\(tag.title)"
        }
        
        if let status = ticketStatus {
            paramString += "&status__title=\(status.title)"
        }
        
        return paramString
    }
}
