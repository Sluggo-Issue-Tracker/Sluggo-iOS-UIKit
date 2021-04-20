//
//  HomeViewController.swift
//  Sluggo
//
//  Created by Troy on 4/19/21.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwind(_ unwindSegue: UIStoryboardSegue) {}
    
    
    @IBAction func backToLoginButton(_ sender: Any) {
        performSegue(withIdentifier: "unwindToLogin", sender: self)
    }

    
}
