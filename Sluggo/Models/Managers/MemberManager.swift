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
    
    public func fetchMemberRecord(completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        var request = URLRequest(url: makeListUrl())
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.token!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
    
    public func updateMemberRecord(_ memberRecord: MemberRecord, completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        var request = URLRequest(url: makeDetailUrl(memberRecord: memberRecord))
        request.httpMethod = "Put"
        
        guard let body = JsonLoader.encode(object: memberRecord) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize member JSON for updateMemberRecord in MemberManager")))
            return
        }
        
        request.httpBody = body
        request.setValue("Bearer \(self.identity.token!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
        
    }
    
    public func listTeamMembers(completionHandler: @escaping(Result<PaginatedList<MemberRecord>, Error>) -> Void) -> Void{
        var request = URLRequest(url: makeListUrl())
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.token!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
}
