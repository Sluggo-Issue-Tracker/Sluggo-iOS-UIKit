//
//  SluggoSidebarContainerViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 4/15/21.
//

import UIKit

class SluggoSidebarContainerViewController: UIViewController {
    // MARK: Outlets
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var sidebarContainerView: UIView!
    @IBOutlet weak var sidebarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var sidebarContainerLeadingConstraint: NSLayoutConstraint!
    
    // MARK: Properties
    var sidebarPresenting: SidebarStatus = .closed
    
    // MARK: Computed
    var sidebarLeadingConstant: CGFloat {
        get {
            let width = sidebarWidthConstraint.constant
            return (sidebarPresenting == .open) ? 0 : -1 * width;
        }
    }
    
    var backgroundOpacity: CGFloat {
        get {
            return (sidebarPresenting == .open) ? 0.4 : 0.0;
        }
    }
    
    var foregroundOpacity: CGFloat {
        get {
            return (sidebarPresenting == .open) ? 1.0 : 0.0;
        }
    }
    
    // MARK: Functions
    @objc func triggerSidebar(_notification: Notification) {
        guard let sidebarState = _notification.userInfo?[Sidebar.USER_INFO_KEY] as? SidebarStatus else {
            print("Sidebar triggered without explicit state.")
            return // TODO log this as an error
        }
        
        sidebarPresenting = sidebarState
        
        updateSidebar()
    }
    
    @IBAction func backgroundTapGestureRecognized(_ sender: UITapGestureRecognizer) {
        print("RECOGNIZED")
        NotificationCenter.default.post(name: .onSidebarTrigger, object: self, userInfo: [Sidebar.USER_INFO_KEY: SidebarStatus.closed])
        
    }
    
    func updateSidebar() {
        sidebarContainerLeadingConstraint.constant = sidebarLeadingConstant
        
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = self.backgroundOpacity
            self.view.alpha = self.foregroundOpacity
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: VC Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
                
        updateSidebar()
        
        // Register for notification of sidebar changes
        NotificationCenter.default.addObserver(self, selector: #selector(triggerSidebar), name: .onSidebarTrigger, object: nil)
        
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

extension Notification.Name {
    static let onSidebarTrigger = Notification.Name(rawValue: "SLGSidebarTriggerNotification")
}
