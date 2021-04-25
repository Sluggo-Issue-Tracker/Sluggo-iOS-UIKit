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
    private var config: Config
    private var token: String
    
    convenience init() {
        self.init(nibName:nil, bundle:nil)
    }

    // This extends the superclass.
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.config = Config()
        self.token = "asdf" // will need to be changed
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    // This is also necessary when extending the superclass.
    required init?(coder aDecoder: NSCoder) {
        self.config = Config()
        self.token = "asdf" // will need to be changed
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isModalInPresentation = true
        persistButton.setImage(UIImage(systemName: "checkmark.square.fill"), for: [.highlighted, .selected])
    }
    
    @IBAction func loginButton(_ sender: Any) {
        
        
        // Sanitize input?
        
        let userString = username.text
        let passString = password.text
        
        //print("User:", userString!)
        //print("Password:", passString!)
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.loginMethod(userString!, passString!)
        }
        
        if(userString!.isEmpty || passString!.isEmpty) {
            // login Error
            print("Login Error")
            return
        } else {
            print("Login Success")
            self.performSegue(withIdentifier: "loginToRoot", sender: self)
            
        }
    }
    
    
    func loginMethod(_ user:String, _ password:String) {
        let userManager = UserManager(config, token: "asdf")
        userManager.doLogin(username: user, password: password) { result in
            switch(result) {
            case .success(let record):
                print(record.key)
                break;
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    @IBAction func persistLoginButton(_ sender: UIButton) {
        sender.isSelected.toggle()
        
        print(sender.isSelected)
    }
}
