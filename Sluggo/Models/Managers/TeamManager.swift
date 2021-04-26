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
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    public func listUserTeams(completionHandler: @escaping(Result<PaginatedList<TeamRecord>, Error>) -> Void) -> Void {
        
        var request = URLRequest(url: URL(string: identity.configData["instanceURL"]! + TeamManager.urlBase)!)
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
}
