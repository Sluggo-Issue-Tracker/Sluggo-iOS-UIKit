//
//  StatusManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

class StatusManager: TeamPaginatedListable {

    static let urlBase = "/statuses/"
    private let identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }

    private func makeDetailUrl(statusRecord: StatusRecord) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + StatusManager.urlBase + "\(statusRecord.id)/")!
    }
    
    private func makeListUrl(page: Int) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + StatusManager.urlBase + "?page=\(page)")!
    }
    
    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<StatusRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
