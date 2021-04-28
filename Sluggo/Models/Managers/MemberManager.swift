//
//  MemberManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class MemberManager {
    static let urlBase = "/members/"
    private var identity: AppIdentity
    
    init(_ identity: AppIdentity) {
        self.identity = identity
    }
    
    private func makeDetailUrl(memberRecord: MemberRecord) -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + MemberManager.urlBase + "\(memberRecord.id)/")!
    }
    
    private func makeListUrl() -> URL {
        return URL(string: identity.baseAddress + TeamManager.urlBase + "\(identity.team!.id)" + MemberManager.urlBase)!
    }
    
    public func fetchTeamMembers(completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        
        let requestBuilder = URLRequestBuilder(url: makeListUrl())
            .setMethod(method: .GET)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func updateMemberRecord(_ memberRecord: MemberRecord, completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        
        guard let body = JsonLoader.encode(object: memberRecord) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize member JSON for updateMemberRecord in MemberManager")))
            return
        }

        let requestBuilder = URLRequestBuilder(url: makeDetailUrl(memberRecord: memberRecord))
            .setData(data: body)
            .setMethod(method: .PUT)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
        
    }
    
    public func listTeamMembers(completionHandler: @escaping(Result<PaginatedList<MemberRecord>, Error>) -> Void) -> Void{
        
        let requestBuilder = URLRequestBuilder(url: makeListUrl())
            .setIdentity(identity: identity)
            .setMethod(method: .GET)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
