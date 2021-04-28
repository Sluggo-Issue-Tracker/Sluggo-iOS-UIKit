//
//  RequestBuilder.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/28/21.
//

import Foundation

enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case PATCH = "PATCH"
    case DELETE = "DELETE"
}

class URLRequestBuilder {
    private var request: URLRequest
    
    init(url: URL) {
        request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    
    func setMethod(method: HTTPMethod) -> URLRequestBuilder {
        request.httpMethod = method.rawValue
        return self
    }
    
    func setData(data: Data) -> URLRequestBuilder {
        request.httpBody = data
        return self
    }
    
    func setIdentity(identity: AppIdentity) {
        request.setValue("Bearer \(self.identity.token!)", forHTTPHeaderField: "Authorization")
        return self
    }
    
    func getRequest() -> URLRequest {
        return request
    }
}
