//
//  TicketManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TicketManager {
    static let urlBase = "/tickets/"
    private var identity: AppIdentity
    
    init(_ identity: AppIdentity) {
        self.identity = identity
    }
    
    private func makeDetailUrl(_ ticketRecord: TicketRecord) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + TicketManager.urlBase + "\(ticketRecord.id)/")!
    }
    
    public func makeListUrl(page: Int, assignedMember: MemberRecord?) -> URL {
        var urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + TicketManager.urlBase + "?page=\(page)"
        if let assignedMember = assignedMember {
            urlString += "&assigned_user__owner__username=\(assignedMember.owner.username)"
        }
        return URL(string: urlString)!
    }
    
    public func listTeamTickets(page: Int, assigned: MemberRecord?, completionHandler: @escaping (Result<PaginatedList<TicketRecord>, Error>) -> Void) -> Void {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page, assignedMember: assigned))
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func listTeamTickets(page: Int, completionHandler: @escaping (Result<PaginatedList<TicketRecord>, Error>) -> Void) -> Void {
        listTeamTickets(page: page, assigned: nil, completionHandler: completionHandler)
    }
    
    public func makeTicket(ticket: WriteTicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)->Void{
        guard let body = JsonLoader.encode(object: ticket) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize ticket JSON for makeTicket in TicketManager")))
            return
        }
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1, assignedMember: nil))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func updateTicket(ticket: TicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)-> Void {
        let writeTicket = WriteTicketRecord(tag_list: ticket.tag_list, assigned_user: ticket.assigned_user?.id, status: ticket.status, title: ticket.title, description: ticket.description, due_date: ticket.due_date)
        guard let body = JsonLoader.encode(object: writeTicket) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize ticket JSON for updateTicket in TicketManager")))
            return
        }
        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(ticket))
            .setMethod(method: .PUT)
            .setData(data: body)
            .setIdentity(identity: self.identity)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
        
    }
}
