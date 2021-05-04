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
    @IBOutlet weak var loginButton: UIButton!
    
    // TODO: AppIdentity be migrated when login flow progressed
    // This should really be managed by the AppDelegate and passed into VCs along
    // segues and otherwise.
    
    // Attempt to load from disk, otherwise, use the new one.
    var identity: AppIdentity
    var completion: (() -> Void)?
    
    init? (coder: NSCoder, identity: AppIdentity, completion: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
        super.init(coder: coder)
    }
    
    // This is also necessary when extending the superclass.
    required init?(coder aDecoder: NSCoder) {
        fatalError("must be created with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        
        persistButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: [.highlighted, .selected])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @IBAction func loginButton(_ sender: Any) {
        let userString = username.text
        let passString = password.text
        
        print("button pressed")
        
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
                // This is hacky but better than nothing
                var rememberMe: Bool = false
                DispatchQueue.main.sync {
                    rememberMe = self.persistButton.isSelected
                }
                if(rememberMe) {
                    let persistenceResult = self.identity.saveToDisk()
                    if(!persistenceResult) {
                        print("SOMETHING WENT WRONG WITH PERSISTENCE!")
                    }
                }
                
                // Segue out of VC
                DispatchQueue.main.async {
                    //self.performSegue(withIdentifier: "loginToRoot", sender: self)
                    self.dismiss(animated: true, completion: self.completion)
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
    
    @IBSegueAction func createRootViewController(_ coder: NSCoder) -> UIViewController? {
        return RootViewController(coder: coder, identity: identity)
    }
}

