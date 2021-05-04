//
//  TeamTableViewController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/3/21.
//

import UIKit

class TeamTableViewController: UITableViewController {
    private var identity: AppIdentity
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be called w/ identity")
    }
}
