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
        do {
            let request = try userManager.doLogin(username: user, password: password)
            print(request?.key)
        } catch RESTException.FailedRequest(let message) { // more would need to be done here.
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
                NSLog("The \"OK\" alert occured.")
                }))
                self.present(alert, animated: true, completion: nil)
            }
        } catch {
            let alert = UIAlertController(title: "Error", message: "some other error ocurred", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            NSLog("The \"OK\" alert occured.")
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func transitionToHome() {
        
        /*
        let rViewController = storyboard?.instantiateViewController(identifier: "rVC") as? RootViewController
            
        view.window?.rootViewController = rViewController
        view.window?.makeKeyAndVisible()
        */
        
        }
}
