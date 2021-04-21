//
//  UserManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class UserManager {
    private var config: Config
    private var token: String?
    
    init(_ config: Config, token: String?) {
        self.config = config
        self.token = token
    }
    
    public func doLogin(username: String, password: String) -> URLRequest {
        let params = ["username":username, "password":password] as Dictionary<String, String>
        var request = URLRequest(url: URL(string: config.getValue(Config.kURL)! + "auth/login/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
    
    public func doLogout() -> URLRequest { // TODO: this is probably incorrect
        var request = URLRequest(url: URL(string: config.getValue(Config.kURL)! + "auth/logout/")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.token!)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        return request
    }
}
