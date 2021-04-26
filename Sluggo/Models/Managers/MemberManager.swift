//
//  MemberManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class MemberManager {
    private var identity: AppIdentity
    private var config: Config
    
    init(_ identity: AppIdentity, _ config: Config) {
        self.identity = identity
        self.config = config
    }
    
    private func makeDetailUrl(memberRecord: MemberRecord) -> URL {
        return URL(string: config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team!.id)" + "/members/" + "\(memberRecord.id)/")!
    }
    
    private func makeListUrl() -> URL {
        return URL(string: config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team!.id)" + "/members/")!
    }
    
    public func fetchMemberRecord(completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        var request = URLRequest(url: makeListUrl())
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
    
    public func updateMemberRecord(_ memberRecord: MemberRecord, completionHandler: @escaping(Result<MemberRecord, Error>) -> Void) -> Void {
        var request = URLRequest(url: makeDetailUrl(memberRecord: memberRecord))
        request.httpMethod = "Put"
        
        guard let body = JsonLoader.encode(memberRecord) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize member JSON for updateMemberRecord in MemberManager")))
            return
        }
        
        request.httpBody = body
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
        
    }
    
    public func listTeamMembers(completionHandler: @escaping(Result<PaginatedList<MemberRecord>, Error>) -> Void) -> Void{
        var request = URLRequest(url: makeListUrl())
        request.httpMethod = "GET"
        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
}
