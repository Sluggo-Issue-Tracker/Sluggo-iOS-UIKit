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

    // MARK: User Invite Manager
    func getUserInvites(completionHandler: @escaping (Result<[UserInviteRecord], Error>) -> Void) {

        let urlString = identity.baseAddress + InviteManager.urlBase
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    public func acceptUserInvite(invite: UserInviteRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let urlString = identity.baseAddress + InviteManager.urlBase + "\(invite.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setMethod(method: .PUT)
            .setIdentity(identity: self.identity)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)

    }

    public func rejectUserInvite(invite: UserInviteRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let urlString = identity.baseAddress + InviteManager.urlBase + "\(invite.id)/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setMethod(method: .DELETE)
            .setIdentity(identity: self.identity)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)

    }

    // MARK: Team Invite Manager
    func getTeamInvites(page: Int,
                        completionHandler: @escaping (Result<PaginatedList<TeamInviteRecord>, Error>) -> Void) {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)/" + "invites/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    func addTeamInvite(user: UserRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)/" + "invites/"

        guard let body = JsonLoader.encode(object: user) else {
            let errorMessage = "Failed to serialize ticket JSON for addTeamInvite in InviteManager"
            completionHandler(.failure(Exception.runtimeError(message: errorMessage)))
            return
        }

        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setData(data: body)
            .setMethod(method: .POST)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }

    func deleteTeamInvite(invite: UserInviteRecord, completionHandler: @escaping(Result<Void, Error>) -> Void) {

        let urlString = identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)/" + "invites/"
        let requestBuilder = URLRequestBuilder(url: URL(string: urlString)!)
            .setIdentity(identity: identity)
            .setMethod(method: .GET)

        JsonLoader.executeEmptyRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
