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
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        return alert
    }
}
