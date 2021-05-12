//
//  TeamManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TeamManager: TeamPaginatedListable {

    
    static let urlBase = "api/teams/"
    private var identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<TeamRecord>, Error>) -> Void) {
        
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + TeamManager.urlBase + "?page=\(page)")!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func getTeam(team: TeamRecord, completionHandler: @escaping(Result<TeamRecord, Error>) -> Void) -> Void {
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + TeamManager.urlBase + "\(team.id)/")!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
