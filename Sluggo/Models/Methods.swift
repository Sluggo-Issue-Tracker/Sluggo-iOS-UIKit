//
//  Methods.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import Foundation

class UnwindState<T: Codable> {
    let manager: TeamPaginatedListable
    var page: Int
    var maxCount: Int
    var codableArray: [T]
    var onSuccess: (([T]) -> Void)?
    var onFailure: ((Error) -> Void)?
    var after: (() -> Void)?
    
    init(manager: TeamPaginatedListable,
         page: Int,
         maxCount: Int,
         codableArray: [T],
         onSuccess: (([T]) -> Void)?,
         onFailure: ((Error) -> Void)?,
         after: (() -> Void)?) {
        
        self.manager = manager
        self.page = page
        self.maxCount = maxCount
        self.codableArray = codableArray
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.after = after
    }
    
    static func unwindPaginationRecurse<T: Codable>(state: UnwindState<T>) -> Void {
        
        state.manager.listFromTeams(page: state.page) {
            (result: Result<PaginatedList<T>, Error>) -> Void in

            switch (result) {
            case .success(let record):
                state.maxCount = record.count
                
                for entry in record.results {
                    state.codableArray.append(entry)
                }
                
                if (state.codableArray.count < state.maxCount) {
                    state.page += 1
                    
                    // tail recurse to get remaining data
                    unwindPaginationRecurse(state: state)
                } else {
                    state.onSuccess?(state.codableArray)
                    state.after?()
                }
                break
            case .failure(let error):
                print("error occured")
                state.onFailure?(error)
                state.after?()
                break
            }
        };
    }

    static func unwindPagination<T: Codable>(manager: TeamPaginatedListable,
                                      startingPage: Int,
                                      onSuccess: (([T]) -> Void)?,
                                      onFailure: ((Error) -> Void)?,
                                      after: (() -> Void)?) -> Void {
        
        let state = UnwindState<T>(manager: manager,
                                   page: startingPage,
                                   maxCount: 0,
                                   codableArray: [],
                                   onSuccess: onSuccess,
                                   onFailure: onFailure,
                                   after: after)
        
        unwindPaginationRecurse(state: state)
    }
}


