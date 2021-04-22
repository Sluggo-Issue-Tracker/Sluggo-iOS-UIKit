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
        
        //print("User:", userString!)
        //print("Password:", passString!)
        
        //loginMethod(userString!, passString!)
        
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
        
        let params = ["username":user, "password":password] as Dictionary<String, String>

        var request = URLRequest(url: URL(string: Config.URL_BASE + "auth/login/")!)
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
        let session = URLSession.shared
        let task = session.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! Dictionary<String, AnyObject>
                print(json)
            } catch {
                print("error")
            }
        })

        task.resume()
        
    }
    
    func transitionToHome() {
        
        /*
        let rViewController = storyboard?.instantiateViewController(identifier: "rVC") as? RootViewController
            
        view.window?.rootViewController = rViewController
        view.window?.makeKeyAndVisible()
        */
        
        
        }


}
