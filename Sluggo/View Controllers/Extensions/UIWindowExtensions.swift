//
//  UIWindowExtensions.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/27/21.
//

import UIKit

// Obtained from Stack Overflow here https://stackoverflow.com/questions/4544489/how-to-remove-a-uiwindow
// Not accounting for pre-iOS 12 because we are targeting latest
extension UIWindow {
    func dismiss() {
        isHidden = true
        windowScene = nil
    }
}
