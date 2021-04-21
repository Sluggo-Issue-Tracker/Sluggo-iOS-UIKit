//
//  Exceptions.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/21/21.
//

import Foundation

enum RESTException: Error {
    case FailedRequest(message: String)
}
