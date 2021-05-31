//
//  InviteManager.swift
//  Sluggo
//
//  Created by Troy on 5/31/21.
//

import Foundation

class InviteManager {

    static let urlBase = "api/users/invites/"
    private var identity: AppIdentity

    init(identity: AppIdentity) {
        self.identity = identity
    }

    func getInvites(completionHandler: @escaping (Result<[InviteRecord], Error>) -> Void) {

        let urlString = identity.baseAddress + InviteManager.urlBase
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
