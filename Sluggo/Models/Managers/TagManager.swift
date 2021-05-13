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
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase + "\(tagRecord.id)/"
        return URL(string: urlString)!
    }

    private func makeListUrl(page: Int) -> URL {
        let urlString = identity.baseAddress + TeamManager.urlBase +
            "\(identity.team!.id)" + TagManager.urlBase + "?page=\(page)"
        return URL(string: urlString)!
    }

    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<TagRecord>, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: makeListUrl(page: page))
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

}
