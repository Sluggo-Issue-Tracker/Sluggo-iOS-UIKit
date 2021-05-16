//
//  AdminTableViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/15/21.
//

import UIKit

class AdminTableViewController: UITableViewController {

    var identity: AppIdentity!

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    init?(coder: NSCoder, identity: AppIdentity) {
        super.init(coder: coder)

        self.identity = identity
    }
}
