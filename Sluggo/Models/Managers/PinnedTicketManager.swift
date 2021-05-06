//
//  PinnedTicketManager.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/5/21.
//

import Foundation

class PinnedTicketManager {
    static let urlBase = "/pinned/"
    private var identity: AppIdentity
    private var member: MemberRecord
    
    init(identity: AppIdentity, member: MemberRecord) {
        self.identity = identity
        self.member = member
    }
    
    private func makeListURL() -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + String(identity.team!.id) + MemberManager.urlBase + PinnedTicketManager.urlBase)!;
    }
    
    private func makeDetailURL(desiredID: String) -> URL {
        return URL(string: makeListURL().absoluteString + "/\(desiredID)/")!
    }
    
    public func fetchPinnedTickets(completionHandler: @escaping(Result<[PinnedTicket], Error>) -> Void) -> Void {
        let requestBuilder = URLRequestBuilder(url: makeListURL())
            .setMethod(method: .GET)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func postPinnedTicket(member: MemberRecord, ticket: TicketRecord, completionHandler: @escaping(Result<PinnedTicket, Error>) -> Void) -> Void {
        
        let writeRecord = WritePinnedTicketRecord(ticketID: ticket.id)
        
        guard let body = JsonLoader.encode(object: writeRecord) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize write pinned ticket record in PinnedTicketManager")))
            return
        }
        
        let requestBuilder = URLRequestBuilder(url: makeListURL())
            .setMethod(method: .POST)
            .setData(data: body)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func deletePinnedTicket(member: MemberRecord, pinned: PinnedTicket, completionHandler: @escaping(Result<ErrorMessage, Error>) -> Void) -> Void {
        
        let requestBuilder = URLRequestBuilder(url: makeDetailURL(desiredID: pinned.id))
            .setMethod(method: .DELETE)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
