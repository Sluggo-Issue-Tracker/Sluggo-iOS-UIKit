//
//  SluggoNavigationController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/27/21.
//

import UIKit

/**
 This class is identical to the Navigation Controller, but enables listening for the team
 changer notification, upon which it will unwind to the root. This prevents potential
 inconsistencies with nested presenting controllers, and enables the user to switch
 from them when something is being presented in another controller.
 
 Note: This only handles the case with regards to navigation presentation, but this is
 OK as modal presentations will block the tab bar.
 */
class SluggoNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didRecieveTeamChange),
                                               name: Constants.Signals.TEAM_CHANGE_NOTIFICATION,
                                               object: nil)
    }

    @objc private func didRecieveTeamChange() {
        self.popToRootViewController(animated: true)
    }

}
