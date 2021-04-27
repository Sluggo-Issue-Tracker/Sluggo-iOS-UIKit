//
//  HomeNavigationController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/27/21.
//

import UIKit

class HomeNavigationController: UINavigationController, IdentityView {
    var identity: AppIdentity?
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? HomeViewController {
            destination.setIdentity(identity: identity!)
        }
    }
    
    required init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func setIdentity(identity: AppIdentity) {
        self.identity = identity
    }
}
