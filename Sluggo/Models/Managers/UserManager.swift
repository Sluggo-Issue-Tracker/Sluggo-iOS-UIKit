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
    
    public func getUser(completitonHandler: @escaping(Result<AuthRecord, Error>) -> Void) {
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + "auth/user/")!)
            .setMethod(method: .GET)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completitonHandler)
    }
    
    public func doLogin(username: String, password: String, completionHandler: @escaping(Result<TokenRecord, Error>) -> Void) -> Void {
        let params = ["username":username, "password":password] as Dictionary<String, String>
        guard let body = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            completionHandler(.failure(Exception.runtimeError(message: "Failed to serialize JSON for doLogin in UserManager")))
            return;
        }
        
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "login/")!)
            .setData(data: body)
            .setMethod(method: .POST)

        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func doLogout(completionHandler: @escaping(Result<LogoutMessage, Error>) -> Void) -> Void { // TODO: this is probably incorrect
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + UserManager.urlBase + "logout/")!)
            .setMethod(method: .POST)
            .setIdentity(identity: self.identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
    
    public func getRecord(identity: AppIdentity, completionHandler: @escaping(Result<AuthRecord, Error>) -> Void) -> Void {
        let requestBuilder = URLRequestBuilder(url: URL(string: identity.baseAddress + "auth/user/")!)
            .setMethod(method: .GET)
            .setIdentity(identity: identity)
        
        JsonLoader.executeCodableRequest(request: requestBuilder.getRequest(), completionHandler: completionHandler)
    }
}
