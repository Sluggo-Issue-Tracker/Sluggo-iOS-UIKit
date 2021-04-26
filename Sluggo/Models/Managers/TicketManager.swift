//
//  TicketManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TicketManager {
    private var identity: AppIdentity
    
    init(_ identity: AppIdentity) {
        self.identity = identity
    }
    
    private func makeDetailUrl(_ ticketRecord: TicketRecord) -> URL {
        return URL(string: identity.configData[Constants.Config.kURL]! + "/api/teams/" + "\(identity.team!.id)" + "/tickets/" + "\(ticketRecord.id)/")!
    }
    
    private func makeListUrl() -> URL {
        return URL(string: identity.configData[Constants.Config.kURL]! + "/api/teams/" + "\(identity.team!.id)" + "/tickets/")!
    }
    
    public func updateTicket(_ ticket: TicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)-> Void {
        var request = URLRequest(url: makeDetailUrl(ticket))
        request.httpMethod = "PUT"
        
        guard let body = JsonLoader.encode(ticket) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize ticket JSON for updateTicket in TicketManager")))
            return
        }
        
        request.httpBody = body
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
        
    }
}
