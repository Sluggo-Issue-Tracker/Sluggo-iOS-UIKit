//
//  PaginatedList.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 4/18/21.
//

import Foundation

struct PaginatedList<T : Codable> : Codable {
    var count: Int
    var next: String?
    var previous: String?
    let results: [T]
    
}
