//
//  StatusManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//
//  Rip pop smoke
//

import Foundation

class StatusManager {
    static let urlBase = "/statuses/"
    private let identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }

    private func makeDetailUrl(memberRecord: MemberRecord) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + MemberManager.urlBase + "\(memberRecord.id)/")!
    }
    
    private func makeListUrl(page: Int) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + MemberManager.urlBase + "?page=\(page)")!
    }
    
    public func listTeamStatuses(page: Int, completionHandler: @escaping(Result<PaginatedList<MemberRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
}
