//
//  LoginViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 4/18/21.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var persistButton: UIButton!
    
    // TODO: AppIdentity be migrated when login flow progressed
    // This should really be managed by the AppDelegate and passed into VCs along
    // segues and otherwise.
    let identity = AppIdentity()
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }

    // This extends the superclass.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // This is also necessary when extending the superclass.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        persistButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: [.highlighted, .selected])
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let userString = username.text
        let passString = password.text
        
        if(userString!.isEmpty || passString!.isEmpty) {
            // login Error
            print("No username or password provided, not attempting login")
            return
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.attemptLogin(username: userString!, password: passString!)
            }
        }
    }
    
    
    func attemptLogin(username: String, password: String) {
        let userManager = UserManager(identity: identity)
        userManager.doLogin(username: username, password: password) { result in
            switch(result) {
            case .success(let record):
                print("Successful login and retrieved token " + record.key)
                
                // Save to identity
                self.identity.token = record.key
                
                // Persistence
                // TODO: Fix calling UI stuff from background thread
                // (maybe have a separate function to move on if login successful?)
                if(self.persistButton.isSelected) { // if user checks "Remember Me?"
                    let persistenceResult = self.identity.saveToDisk()
                    if(!persistenceResult) {
                        print("SOMETHING WENT WRONG WITH PERSISTENCE!")
                    }
                }
                
                // Segue out of VC
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "loginToRoot", sender: self)
                }
                
                break;
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func persistLoginButton(_ sender: Any) {
        self.persistButton.isSelected.toggle()
        print(self.persistButton.isSelected)
    }
}

