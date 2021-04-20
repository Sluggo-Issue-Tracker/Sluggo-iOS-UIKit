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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        
        // Sanitize input?
        
        let userString = username.text
        let passString = password.text
        
        print("User:", userString!)
        print("Password:", passString!)
        
        loginMethod(userString!, passString!)
        
        
    }
    
    func loginMethod(_ user:String, _ password:String) {
        
        return
    }

}
