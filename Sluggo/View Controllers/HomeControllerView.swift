//
//  HomeControllerView.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/26/21.
//

import UIKit

class HomeNavigationController: UINavigationController {
    var identity: AppIdentity
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("you fucked up")
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("custom prepare")
        super.prepare(for: segue, sender: sender)
    }
    
    @IBSegueAction func createHome(coder: NSCoder, sender: Any?, segueIdentifier: String?)-> HomeViewController? {
        print("coder")
        return HomeViewController(coder: coder)
    }
    
    
    
}
