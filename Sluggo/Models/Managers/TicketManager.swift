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
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.getTeam().id)" + "/tickets/" + "\(ticketRecord.id)/"
    }
    
    private func makeListUrl() -> String {
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.getTeam().id)" + "/tickets/"
    }
    
    public func updateTicket(_ ticket: TicketRecord) -> URLRequest {
        var request = URLRequest(url: URL(string: makeDetailUrl(ticket))!)
        request.httpMethod = "PUT"
        request.httpBody = JsonLoader.encode(ticket)
        request.setValue("Bearer \(self.identity.getToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
