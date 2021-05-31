//
//  PendingInvitesViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/30/21.
//

import UIKit

class PendingInvitesViewController: UITableViewController {
    var identity: AppIdentity!
    var generateSegueableController: ((AppIdentity, MemberRecord?) -> UIViewController?)?
    var generateMemberDetail: ((MemberRecord) -> String?)?
    private var maxNumber: Int = 0
    private var members: [MemberRecord] = []
    private var isFetching  = false
    private var semaphore = DispatchSemaphore(value: 1)

    required init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        self.configureRefreshControl()
        self.handleRefreshAction()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRefreshAction),
                                               name: .refreshMembers, object: nil)

        self.tableView.allowsSelection = (generateSegueableController != nil)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pInviteCell", for: indexPath) as UITableViewCell
        let member = self.members[indexPath.row]
        cell.textLabel?.text = member.owner.username
        cell.detailTextLabel?.text = generateMemberDetail?(member) ?? ""

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let generateController = self.generateSegueableController else { return }

        guard let viewController = generateController(identity, self.members[indexPath.row]) else { return }

        if let navController = self.navigationController {
            navController.show(viewController, sender: self)
        } else {
            self.present(viewController, animated: true, completion: nil)
        }
    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()

            let onSuccess = { (members: [MemberRecord]) -> Void in
                self.members = members
            }

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                self.semaphore.signal()
            }

            let memberManager = MemberManager(identity: self.identity)
            unwindPagination(manager: memberManager,
                             startingPage: 1,
                             onSuccess: onSuccess,
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
        }
    }

    @IBAction func acceptInvite(_ sender: Any) {
        print("Accepted!")
    }
}
