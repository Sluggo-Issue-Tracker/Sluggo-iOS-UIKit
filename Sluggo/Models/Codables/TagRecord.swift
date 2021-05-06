//
//  TagRecord.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/25/21.
//

import Foundation
import NullCodable

struct TagRecord: Codable {
    var id: Int
    var object_uuid: UUID
    var title: String
    var created: Date
    @NullCodable var activated: Date?
    @NullCodable var deactivated: Date?

}
