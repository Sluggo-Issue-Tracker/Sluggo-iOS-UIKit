//
//  InviteManager.swift
//  Sluggo
//
//  Created by Troy on 5/31/21.
//

import Foundation

class InviteManager: TeamPaginatedListable {

    static let urlBase = "api/teams/"
    private var identity: AppIdentity

    init(identity: AppIdentity) {
        self.identity = identity
    }

    func listFromTeams(page: Int, completionHandler: @escaping (Result<PaginatedList<TeamRecord>, Error>) -> Void) {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)"
            + "/invites/" + "?page=\(page)"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
