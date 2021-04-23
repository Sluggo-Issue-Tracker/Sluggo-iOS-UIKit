//
//  AppIdentity.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class AppIdentity {
    private var _authenticatedUser: UserRecord
    private var _team: TeamRecord
    private var _token: String
    
    var authenticatedUser: UserRecord {
        get { return _authenticatedUser }
        set { _authenticatedUser = newValue }
    }

    var team: TeamRecord {
        get { return _team }
        set { _team = newValue }
    }
    
    var token: String {
        get { return _token }
        set { _token = newValue }
    }
    
    init(_ authenticatedUser: UserRecord, _ team: TeamRecord, _ token: String) {
        self._authenticatedUser = authenticatedUser
        self._team = team
        self._token = token
    }
}
