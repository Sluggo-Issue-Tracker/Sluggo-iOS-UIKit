//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class AppIdentity {
    private var authenticatedUser: UserRecord
    private var team: TeamRecord
    private var token: String
    
    init(_ authenticatedUser: UserRecord, _ team: TeamRecord, _ token: String) {
        self.authenticatedUser = authenticatedUser
        self.team = team
        self.token = token
    }
    
    public func getAuthenticatedUser() -> UserRecord {
        return authenticatedUser
    }
    
    public func getTeam() -> TeamRecord {
        return team
    }
    
    public func getToken() -> String {
        return token
    }
    
    public func setAuthenticatedUser(_ authenticatedUser: UserRecord) {
        self.authenticatedUser = authenticatedUser
    }
    
    public func setTeam(_ team: TeamRecord) {
        self.team = team
    }
    
    public func setToken(_ token: String) {
        self.token = token
    }
}
