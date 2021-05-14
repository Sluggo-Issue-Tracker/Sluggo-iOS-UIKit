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
    
    public func makeListUrl(page: Int, queryParams: TicketFilterParameters) -> URL {
        var urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + TicketManager.urlBase + "?page=\(page)"
        urlString += queryParams.toParamString()
        
        return URL(string: urlString)!
    }
    
    // TODO: nest a params class that will make querying slightly easier
    public func makeListUrl(page: Int, assignedMember: MemberRecord?) -> URL {
        let queryParams = TicketFilterParameters(assignedUser: assignedMember)
        
        return makeListUrl(page: page, queryParams: queryParams)
    }
    
    public func listTeamTickets(page: Int, queryParams: TicketFilterParameters, completionHandler: @escaping (Result<PaginatedList<TicketRecord>, Error>) -> Void) -> Void {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page, queryParams: queryParams))
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func makeTicket(ticket: WriteTicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)->Void{
        guard let body = JsonLoader.encode(object: ticket) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize ticket JSON for makeTicket in TicketManager")))
            return
        }
        
        // TODO: this works but the page here does effectively nothing. I think for clarity introducing a separate
        // function for making the url might be beneficial
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: 1, assignedMember: nil))
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func updateTicket(ticket: TicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)-> Void {
        let writeTicket = WriteTicketRecord(tag_list: ticket.tag_list,
                                            assigned_user: ticket.assigned_user?.id,
                                            status: ticket.status,
                                            title: ticket.title,
                                            description: ticket.description,
                                            due_date: ticket.due_date)
        
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
