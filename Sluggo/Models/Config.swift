//
//  Config.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/19/21.
//

import Foundation

struct Config {
    static let URL_BASE = "http://127.0.0.1:8000/"
    static let kURL = "url"
    
    private var configData = [
        kURL: URL_BASE // enable change if need be
    ]
    
    public func getValue(_ key: String) -> String? {
        return configData[key]
    }
}
