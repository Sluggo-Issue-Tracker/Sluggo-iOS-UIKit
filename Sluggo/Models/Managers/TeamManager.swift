//
//  TeamManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TeamManager {
    static let urlBase = "api/teams/"
    private var identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    public func listUserTeams(completionHandler: @escaping(Result<PaginatedList<TeamRecord>, Error>) -> Void) -> Void {
        
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + TeamManager.urlBase)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
