//
//  LaunchViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 4/25/21.
//

import UIKit

class LaunchViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let remember = false
        
        if(remember) {
            // Call login function from remembered. If failed go to login
        } else {
            sleep(1)
            self.performSegue(withIdentifier: "showLogin", sender: self)
        }
        
        
    }
    
    func continueLogin() {
        sleep(3)
        self.performSegue(withIdentifier: "automaticLogin", sender: self)
    }
    
}
