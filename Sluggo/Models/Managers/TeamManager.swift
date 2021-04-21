//
//  TeamManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TeamManager {
    static let urlBase = "/api/teams/"
    private var identity: AppIdentity
    private var config: Config
    
    
    init(_ identity: AppIdentity, _ config: Config) {
        self.identity = identity
        self.config = config
    }
    
    public func listUserTeams() throws -> PaginatedList<TeamRecord>? {
        
        var request = URLRequest(url: URL(string: config.getValue(Config.kURL)! + TeamManager.urlBase)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.getToken())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        return try JsonLoader.executeCodableRequest(request: request)
    }
}
