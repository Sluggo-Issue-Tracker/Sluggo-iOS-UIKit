//
//  LaunchViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 4/25/21.
//

import UIKit

class LaunchViewController: UIViewController {
    
    var identity: AppIdentity
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must create class with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        let remember = (self.identity.token != nil)
        let userManager = UserManager(identity: self.identity)
        
        if(remember) {
            // Call login function from remembered. If failed go to login
            userManager.getUser() { result in
                switch result {
                case .success(let record):
                    DispatchQueue.main.sync {
                        self.performSegue(withIdentifier: "automaticLogin", sender: self)
                    }
                    break
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.sync {
                        self.showLogin()
                    }
                }
            }
        } else {
            self.showLogin()
        }
    }
    
    func showLogin() {
        if let vc = self.storyboard?.instantiateViewController(identifier: "loginPage", creator: {coder in
            return LoginViewController(coder: coder, identity: self.identity, completion: {
                self.continueLogin()
            })
        }) {
            vc.isModalInPresentation = true
            self.present(vc, animated: true)
        }
    }
    
    func continueLogin() {
//        sleep(3)
        self.performSegue(withIdentifier: "automaticLogin", sender: self)
    }
    
    @IBSegueAction func createRoot(_ coder: NSCoder) -> UIViewController? {
        return RootViewController(coder: coder, identity: identity)
    }
}
