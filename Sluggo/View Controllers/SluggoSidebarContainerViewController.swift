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
    var sidebarPresenting = false
    
    // MARK: Computed
    var sidebarLeadingConstant: CGFloat {
        get {
            let width = sidebarWidthConstraint.constant
            return sidebarPresenting ? 0 : -1 * width;
        }
    }
    
    var backgroundOpacity: CGFloat {
        get {
            return sidebarPresenting ? 0.4 : 0.0;
        }
    }
    
    // MARK: Functions
    @objc func triggerSidebar() {
        sidebarPresenting = !sidebarPresenting
        
        updateSidebar()
    }
    
    func updateSidebar() {
        sidebarContainerLeadingConstraint.constant = sidebarLeadingConstant
        view.isUserInteractionEnabled = sidebarPresenting
        
        UIView.animate(withDuration: 0.25) {
            self.backgroundView.alpha = self.backgroundOpacity
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
