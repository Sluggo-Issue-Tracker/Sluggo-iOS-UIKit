//
//  TagManger.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class TagManager: TeamPaginatedListable {

    
    static let urlBase = "/tags/"
    private let identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    private func makeDetailUrl(tagRecord: TagRecord) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + TagManager.urlBase + "\(tagRecord.id)/")!
    }
    
    private func makeListUrl(page: Int) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + TagManager.urlBase + "?page=\(page)")!
    }
    
    func listFromTeams<T>(page: Int, completionHandler: @escaping (Result<PaginatedList<T>, Error>) -> Void) where T : Decodable, T : Encodable {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
}
