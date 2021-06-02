//
//  ViewControllerExtensions.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/10/21.
//

import UIKit

extension UIViewController {
    func presentError(error: Error, completion: ((UIAlertAction) -> Void)?) {
        UIAlertController.createAndPresentError(view: self, error: error, completion: completion)
    }

    func presentError(error: Error) {
        UIAlertController.createAndPresentError(view: self, error: error)
    }

    func presentErrorFromMainThread(error: Error) {
        DispatchQueue.main.async {
            self.presentError(error: error)
        }
    }

    func processResult<T>(result: Result<T, Error>, onSuccess: @escaping ((T) -> Void),
                          onError: ((Error) -> Void)?, after: (() -> Void)?) {
        DispatchQueue.main.sync {
            switch result {
            case .success(let successObj):
                onSuccess(successObj)
            case .failure(let error):
                if let errorHandler = onError {
                    errorHandler(error)
                } else {
                    presentError(error: error)
                }
            }

            // Continue chains if necessary
            after?()
        }
    }

    func processResult<T>(result: Result<T, Error>, onSuccess: @escaping ((T) -> Void), after: (() -> Void)?) {
        self.processResult(result: result, onSuccess: onSuccess, onError: nil, after: after)
    }

    func processResult<T>(result: Result<T, Error>, onSuccess: @escaping ((T) -> Void)) {
        self.processResult(result: result, onSuccess: onSuccess, onError: nil, after: nil)
    }
}
