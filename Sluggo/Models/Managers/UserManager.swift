//
//  UserManager.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/20/21.
//

import Foundation

class UserManager {
    static let urlBase = "auth/"
    private var identity: AppIdentity
    
    init(identity: AppIdentity) {
        self.identity = identity
    }
    
    public func doLogin(username: String, password: String, completionHandler: @escaping(Result<TokenRecord, Error>) -> Void) -> Void {
        let params = ["username":username, "password":password] as Dictionary<String, String>
        var request = URLRequest(url: URL(string: identity.baseAddress + UserManager.urlBase + "login/")!)
        request.httpMethod = "POST"
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize JSON for doLogin in UserManager")))
            return;
        }
        request.httpBody = body;
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
    
    public func doLogout(token: String, completionHandler: @escaping(Result<LogoutMessage, Error>) -> Void) -> Void { // TODO: this is probably incorrect
        var request = URLRequest(url: URL(string: identity.baseAddress + UserManager.urlBase + "logout/")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        JsonLoader.executeCodableRequest(request: request, completionHandler: completionHandler)
    }
}
