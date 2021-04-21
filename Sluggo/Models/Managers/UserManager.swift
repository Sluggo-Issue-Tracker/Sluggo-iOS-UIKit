//
//  UserManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class UserManager {
    private var config: Config
    
    init(_ config: Config, token: String?) {
        self.config = config
    }
    
    public func doLogin(username: String, password: String) throws -> TokenRecord? {
        let params = ["username":username, "password":password] as Dictionary<String, String>
        var request = URLRequest(url: URL(string: config.getValue(Config.kURL)! + "auth/login/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return try JsonLoader.executeCodableRequest(request: request)
    }
    
    public func doLogout(token: String) throws -> ErrorMessage? { // TODO: this is probably incorrect
        var request = URLRequest(url: URL(string: config.getValue(Config.kURL)! + "auth/logout/")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return try JsonLoader.executeCodableRequest(request: request)
    }
}
