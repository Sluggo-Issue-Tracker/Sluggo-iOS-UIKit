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
        
        print("User:", userString!)
        print("Password:", passString!)
        
        loginMethod(userString!, passString!)
        
        // TODO: programatically segue to root view
    }
    
    func loginMethod(_ user:String, _ password:String) {
        let userManager = UserManager(config, token: nil)
        let request = userManager.doLogin(username: user, password: password)
    
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            if let json: TokenRecord? = JsonLoader.decode(data!) {
                print("data")
            }
        })

        task.resume()
    }

}
