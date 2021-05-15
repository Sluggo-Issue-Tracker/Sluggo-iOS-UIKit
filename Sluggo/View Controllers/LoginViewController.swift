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
    @IBOutlet var instanceURL: UITextField!
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
        let instString = instanceURL.text

        print("button pressed")

        if userString!.isEmpty || passString!.isEmpty || instString!.isEmpty {
            // login Error
            print("No username or password provided, not attempting login")
            return
        } else {
            DispatchQueue.global(qos: .userInitiated).async {
                self.identity.baseAddress = instString!
                self.attemptLogin(username: userString!, password: passString!)
            }
        }
    }

    func attemptLogin(username: String, password: String) {
        let userManager = UserManager(identity: identity)
        userManager.doLogin(username: username, password: password) { result in
            switch result {
            case .success(let record):
                print("Successful login and retrieved token " + record.key)

                // Save to identity
                self.identity.token = record.key

                // Wait for user record to also be fetched
                userManager.getUser { result in
                    switch result {
                    case .success(let userRecord):
                        self.identity.authenticatedUser = userRecord

                        // Segue out of VC
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: self.completion)
                        }

                    case .failure(let error):
                        print("FAILURE!")
                        DispatchQueue.main.sync {
                            UIAlertController.createAndPresentError(view: self, error: error, completion: nil)
                        }
                    }
                }

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
        self.identity.setPersistData(persist: self.persistButton.isSelected)
        print(self.persistButton.isSelected)
    }
}
