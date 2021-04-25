//
//  TicketManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TicketManager {
    private var identity: AppIdentity
    private var config: Config
    
    init(_ identity: AppIdentity, _ config: Config) {
        self.identity = identity
        self.config = config
    }
    
    private func makeDetailUrl(_ ticketRecord: TicketRecord) -> String {
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team.id)" + "/tickets/" + "\(ticketRecord.id)/"
    }
    
    private func makeListUrl() -> String {
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team.id)" + "/tickets/"
    }
    
    public func updateTicket(_ ticket: TicketRecord, completionHandler: @escaping(Result<TicketRecord, Error>) -> Void)-> Void {
        var request = URLRequest(url: URL(string: makeDetailUrl(ticket))!)
        request.httpMethod = "PUT"
        
        guard let body = JsonLoader.encode(ticket) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize ticket JSON for updateTicket in Ticket")))
            return
        }
        
        request.httpBody = body
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
        
    }
}
