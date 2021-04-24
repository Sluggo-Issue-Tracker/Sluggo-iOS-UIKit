//
//  Exceptions.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/21/21.
//

import Foundation
import UIKit

enum RESTException: Error {
    case failedRequest(message: String)
}

enum Exception: Error {
    case runtimeError(message: String)
}

extension UIAlertController {
    static func errorController(error: Error) -> UIAlertController {
        // Setup message
        var message: String?
        
        if let failedRequestError = error as? RESTException {
            switch(failedRequestError) {
            case .failedRequest(let errMsg):
                message = errMsg
            }
        }
        
        if let exceptionError = error as? Exception {
            switch(exceptionError) {
            case .runtimeError(let errMsg):
                message = errMsg
            }
        }
        
        let alert = UIAlertController(title: "Error", message: message ?? "Error message not provided", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
}
