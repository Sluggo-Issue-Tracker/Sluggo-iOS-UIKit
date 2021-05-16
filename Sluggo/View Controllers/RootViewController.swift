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
    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeLeft: UISwipeGestureRecognizer!

    var mainTabBarController: UITabBarController?

    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("must be called with identity")
    }
    // swiftlint:disable:next identifier_name
    @objc func onSidebarNotificationRecieved(_notification: Notification) {
        guard let status = _notification.userInfo?[Sidebar.USER_INFO_KEY] as? SidebarStatus else {
            return
        }

        updateForSidebarStatus(status: status)
    }

    func updateForSidebarStatus(status: SidebarStatus) {
        sidebarContainerView.isUserInteractionEnabled = (status == .open) ? true : false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(onSidebarNotificationRecieved),
                                               name: .onSidebarTrigger, object: nil)

        // Do any additional setup after loading the view.

        // MARK: Attach admin if relevant
        getMember(completionHandler: attachAdminIfMemberAdmin)
    }

    func getMember(completionHandler: @escaping ((MemberRecord) -> Void)) {
        let memberManager = MemberManager(identity: identity)
        memberManager.getMemberRecord(user: identity.authenticatedUser!, identity: identity) { result in
            switch result {
            case .success(let member):
                completionHandler(member)
            case .failure:
                // Silently fails, for now
                // TODO: is there a better approach?
                print("Getting the member failed.")
            }
        }
    }

    func attachAdminIfMemberAdmin(member: MemberRecord) {
        if member.role == "AD" {
            // Attach admin VC
            DispatchQueue.main.async {

                if let adminVC = UIStoryboard(name: "Admin",
                                              bundle: Bundle.main)
                    .instantiateInitialViewController() as? AdminTableViewController {
                    adminVC.identity = self.identity // Does this create a race condition?

                    // Wrap this in a navigation controller
                    let navVC = UINavigationController(rootViewController: adminVC)

                    // Create bar button item
                    let adminBarButtonImage = UIImage(systemName: "shield")
                    let barItem = UITabBarItem(title: "Admin", image: adminBarButtonImage, selectedImage: nil)
                    navVC.tabBarItem = barItem

                    // Attach VC
                    self.mainTabBarController?.viewControllers?.append(navVC)
                }
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "tabControllerEmbed":
            mainTabBarController = segue.destination as? UITabBarController
        default:
            break
        }
        super.prepare(for: segue, sender: sender)
    }

    // MARK: - Navigation

    // these are interesting.
    // while connecting them from view controller segues in the tab bar controller
    // did not actually call these, wrapping each tab in a navigation controlller
    // in the other storybaord and *then* connecting them to these handlers seems
    // to have worked.
    @IBSegueAction func createHome(_ coder: NSCoder) -> HomeTableViewController? {
        return HomeTableViewController(coder: coder, identity: identity)
    }

    @IBSegueAction func createTicket(_ coder: NSCoder) -> TicketListController? {
        return TicketListController(coder: coder, identity: identity)
    }

    @IBSegueAction func createMembers(_ coder: NSCoder) -> MemberListViewController? {
        return MemberListViewController(coder: coder, identity: identity)
    }

    @IBAction func receivedGesture() {
        NotificationCenter.default.post(name: .onSidebarTrigger,
                                        object: self, userInfo: [Sidebar.USER_INFO_KEY: SidebarStatus.open])
    }
    @IBAction func receieveLeft() {
        NotificationCenter.default.post(name: .onSidebarTrigger,
                                        object: self, userInfo: [Sidebar.USER_INFO_KEY: SidebarStatus.closed])
    }
    @IBSegueAction func showSidebar(_ coder: NSCoder) -> UIViewController? {
        return SluggoSidebarContainerViewController(coder: coder, identity: self.identity)
    }
}
