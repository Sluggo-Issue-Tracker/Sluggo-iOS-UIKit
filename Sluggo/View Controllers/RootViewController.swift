//
//  RootViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/17/21.
//

import UIKit

class RootViewController: UIViewController {
    @IBOutlet weak var mainContainerView: UIView! // contains the main app and tab bar controller
    @IBOutlet weak var sidebarContainerView: UIView! // contains the sidebar container view controller
    
    @objc func onSidebarNotificationRecieved(_notification: Notification) {
        guard let status = _notification.userInfo?[Sidebar.USER_INFO_KEY] as? SidebarStatus else {
            return;
        }
        
        updateForSidebarStatus(status: status)
    }
    
    func updateForSidebarStatus(status: SidebarStatus) {
        sidebarContainerView.isUserInteractionEnabled = (status == .open) ? true : false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onSidebarNotificationRecieved), name: .onSidebarTrigger, object: nil)

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
