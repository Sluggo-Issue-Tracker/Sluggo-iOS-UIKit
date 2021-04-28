//
//  RootViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/17/21.
//

import UIKit

class RootViewController: UIViewController {
    private var identity: AppIdentity
    @IBOutlet weak var mainContainerView: UIView! // contains the main app and tab bar controller
    @IBOutlet weak var sidebarContainerView: UIView! // contains the sidebar container view controller
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("must be called with identity")
    }
        
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

    // MARK: - Navigation

    
    // these are interesting.
    // while connecting them from view controller segues in the tab bar controller
    // did not actually call these, wrapping each tab in a navigation controlller
    // in the other storybaord and *then* connecting them to these handlers seems
    // to have worked.
    @IBSegueAction func createHome(_ coder: NSCoder) -> HomeViewController? {
        return HomeViewController(coder: coder, identity: identity)
    }
    
    @IBSegueAction func createTicket(_ coder: NSCoder) -> TicketListController? {
        return TicketListController(coder: coder, identity: identity)
    }
}
