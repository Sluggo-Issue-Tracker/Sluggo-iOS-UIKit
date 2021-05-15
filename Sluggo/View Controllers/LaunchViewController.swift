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

        if remember {
            // Call login function from remembered. If failed go to login
            userManager.getUser { loginResult in
                switch loginResult {
                case .success( _):
                    // Need to also check for invalid saved team
                    self.tryTeam()
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

    // runs on a background thread
    private func tryTeam() {
        if let team = identity.team {
            let teamManager = TeamManager(identity: self.identity)
            teamManager.getTeam(team: team) { result in
                switch result {
                case .success(let teamRecord):
                    self.identity.team = teamRecord
                    DispatchQueue.main.sync {
                        self.continueLogin()
                    }
                case .failure(let error):
                    print(error)
                    DispatchQueue.main.sync {
                        self.showTeams()
                    }
                }
            }
        } else {
            DispatchQueue.main.sync {
                self.showTeams()
            }
        }
    }

    func showLogin() {
        if let view = self.storyboard?.instantiateViewController(identifier: "loginPage", creator: {coder in
            return LoginViewController(coder: coder, identity: self.identity, completion: {
                self.showTeams()
            })
        }) {
            view.isModalInPresentation = true
            self.present(view, animated: true)
        }
    }

    func showTeams() {
        if let view = self.storyboard?.instantiateViewController(identifier: "TableViewContainer", creator: {coder in
            return TeamSelectorContainerViewController(coder: coder, identity: self.identity, completion: {
                self.continueLogin()
            }, failure: {

                // reset the data, go back to the login page.
                self.identity.token = nil
                self.identity.authenticatedUser = nil
                self.identity.team = nil

                self.showLogin()
            })
        }) {
            view.isModalInPresentation = true
            self.present(view, animated: true)
        }
    }

    func continueLogin() {
        self.performSegue(withIdentifier: "automaticLogin", sender: self)
    }

    @IBSegueAction func createRoot(_ coder: NSCoder) -> UIViewController? {
        return RootViewController(coder: coder, identity: identity)
    }
}
