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
    var adminController: UIViewController?

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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateAdminAttachment),
                                               name: Constants.Signals.TEAM_CHANGE_NOTIFICATION,
                                               object: nil)

        // Do any additional setup after loading the view.

        // MARK: Attach admin if relevant
        updateAdminAttachment()
    }

    @objc func updateAdminAttachment() {
        getMember(completionHandler: updateAdminAttachmentForMemberRole)
    }

    func logOutAction() {
        // This needs to be done in a specific order to avoid nil exceptions
        // First, dismiss the main view controller and sidebar
        self.mainTabBarController?.dismiss(animated: true, completion: {
            // Assume we are in the key window
            let keyWindow = UIApplication.shared.keyWindow

            // Setup temporary window to make it look like we don't cut in and out
            // Relies on logo VC being identical in nature to existing VC
            let temporaryLogoWindow = UIWindow()
            let logoStoryboard = UIStoryboard(name: "TitleScreen", bundle: Bundle.main)
            let logoVC = logoStoryboard.instantiateInitialViewController()
            temporaryLogoWindow.rootViewController = logoVC

            // Make new logo window visible
            temporaryLogoWindow.makeKeyAndVisible()

            // Dismiss our old window after this has been made key and visible
            keyWindow?.dismiss()

            // Hopefully the user cannot access anything now
            // We don't do background calls to API so this *shouldn't* crash
            // Remove AppIdentity persistence file
            _ = AppIdentity.deletePersistenceFile()

            // After this is done, make a call to reconfigure
            // Reconfiguring will remove the logo window if it exists
            guard let application = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            application.configureInitialViewController()
        })
    }

    func getMember(completionHandler: @escaping ((MemberRecord) -> Void)) {
        let memberManager = MemberManager(identity: identity)
        memberManager.getMemberRecord(user: identity.authenticatedUser!, identity: identity) { result in
            switch result {
            case .success(let member):
                completionHandler(member)
            case .failure:
                // Silently fails, for now
                print("Getting the member failed.")
            }
        }
    }

    func updateAdminAttachmentForMemberRole(member: MemberRecord) {
        if member.role == "AD" {
            // Attach admin VC
            DispatchQueue.main.async {
                if self.adminController != nil { return }
                if let adminVC = UIStoryboard(name: "Admin",
                                              bundle: Bundle.main)
                    .instantiateInitialViewController() as? AdminTableViewController {
                    adminVC.identity = self.identity // Does this create a race condition?

                    // Wrap this in a navigation controller
                    let navVC = SluggoNavigationController(rootViewController: adminVC)

                    // Create bar button item
                    let adminBarButtonImage = UIImage(systemName: "shield")
                    let barItem = UITabBarItem(title: "Admin", image: adminBarButtonImage, selectedImage: nil)
                    navVC.tabBarItem = barItem

                    // Attach VC
                    self.mainTabBarController?.viewControllers?.append(navVC)

                    // Track it here for removal
                    self.adminController = navVC
                }
            }
        } else {
            // Filter the admin controller out of the tab bar view controllers
            // This *should* remove the view controller which will then deallocate automatically
            DispatchQueue.main.async {
                self.mainTabBarController?.viewControllers =
                    self.mainTabBarController?.viewControllers?.filter { $0 != self.adminController }
                self.adminController = nil
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
        // Determine if feasible here
        let shouldPresentSidebar = determineIfPresenting()

        if shouldPresentSidebar {
            NotificationCenter.default.post(name: .onSidebarTrigger,
                                            object: self, userInfo: [Sidebar.USER_INFO_KEY: SidebarStatus.open])
        }
    }

    @IBAction func receieveLeft() {
        NotificationCenter.default.post(name: .onSidebarTrigger,
                                        object: self, userInfo: [Sidebar.USER_INFO_KEY: SidebarStatus.closed])
    }
    @IBSegueAction func showSidebar(_ coder: NSCoder) -> UIViewController? {
        let sidebarContainerVC = SluggoSidebarContainerViewController(coder: coder, identity: self.identity)
        sidebarContainerVC?.logOutAction = self.logOutAction

        return sidebarContainerVC
    }

    private func determineIfPresenting() -> Bool {
        /*
         * Some notes on the below implementation:
         * We determine if we can present based on the number of VCs in the
         * navigation stack of the selected tab controller. This is acceptable, because
         * navigation presentation is susceptible to still recieving the
         * sidebar gestures.
         *
         * Modal presentation is *not* susceptible to this, and so does not
         * need to be accounted for here.
         */
        guard let tabBarControllerVCs = mainTabBarController?.viewControllers
        else { return false } // return false if something goes wrong in determining

        let selectedTabVC = self.mainTabBarController?.selectedViewController
        if let navVC = selectedTabVC as? UINavigationController {
            if navVC.viewControllers.count > 1 {
                // More than one view controller present
                return false
            }
        }

        return true
    }
}
