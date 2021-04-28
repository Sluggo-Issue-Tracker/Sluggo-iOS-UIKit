//
//  HomeViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/15/21.
//

import UIKit

class HomeViewController: UIViewController {
    
    public var identity: AppIdentity
    
    init?(coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("identity must be passed by ctor")
    }
    
    @IBAction func pushDaButton(_ sender: Any) {
        NotificationCenter.default.post(Notification(name: .onSidebarTrigger, userInfo: [Sidebar.USER_INFO_KEY : SidebarStatus.open]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(identity.token!)
        
        
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
