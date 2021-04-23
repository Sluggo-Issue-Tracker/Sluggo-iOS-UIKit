//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

struct AppIdentity {
    var authenticatedUser: UserRecord
    var team: TeamRecord
    var token: String
    
    init(authenticatedUser: UserRecord, team: TeamRecord, token: String) {
        self.authenticatedUser = authenticatedUser
        self.team = team
        self.token = token
    }
}
