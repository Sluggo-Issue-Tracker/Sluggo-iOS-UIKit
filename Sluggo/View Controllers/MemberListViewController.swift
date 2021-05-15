//
//  MemberListViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/13/21.
//
import UIKit

class MemberListViewController: UITableViewController {
    var identity: AppIdentity!
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
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return members.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemberCell", for: indexPath) as UITableViewCell
        let member = self.members[indexPath.row]
        cell.textLabel?.text = member.owner.username

        return cell
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

}
