//
//  TeamListable.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

protocol TeamPaginatedListable {
    func listFromTeams<T: Codable>(page: Int, completionHandler: @escaping(Result<PaginatedList<T>, Error>) -> Void) -> Void
}
