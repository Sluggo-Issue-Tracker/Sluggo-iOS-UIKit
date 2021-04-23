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
    
    private func makeDetailUrl(_ memberRecord: MemberRecord) -> String {
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team.id)" + "/members/" + "\(memberRecord.id)/"
    }
    
    private func makeListUrl() -> String {
        return config.getValue(Config.kURL)! + "/api/teams/" + "\(identity.team.id)" + "/members/"
    }
    
//    public func fetchMemberRecord() throws -> MemberRecord {
//        var request = URLRequest(url: URL(string: makeListUrl())!)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return try JsonLoader.executeCodableRequest(request: request)
//    }
//    
//    public func updateMemberRecord(_ memberRecord: MemberRecord) throws -> MemberRecord {
//        var request = URLRequest(url: URL(string: makeDetailUrl(memberRecord))!)
//        request.httpMethod = "Put"
//        request.httpBody = JsonLoader.encode(memberRecord)
//        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return try JsonLoader.executeCodableRequest(request: request)
//        
//    }
//    
//    public func listTeamMembers() throws -> PaginatedList<MemberRecord> {
//        var request = URLRequest(url: URL(string: makeListUrl())!)
//        request.httpMethod = "GET"
//        request.setValue("Bearer \(self.identity.token)", forHTTPHeaderField: "Authorization")
//        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
//        
//        return try JsonLoader.executeCodableRequest(request: request)
//    }
}
