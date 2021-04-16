//
//  HomeViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/15/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBAction func pushDaButton(_ sender: Any) {
        print("We are in fact doing things")
        NotificationCenter.default.post(Notification(name: .onSidebarTrigger))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
