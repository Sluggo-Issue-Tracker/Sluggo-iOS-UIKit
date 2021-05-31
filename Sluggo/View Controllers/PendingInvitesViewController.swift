//
//  PendingInvitesViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/30/21.
//

import UIKit

class PendingInvitesViewController: UITableViewController {
    var identity: AppIdentity!
    var generateSegueableController: ((AppIdentity, TeamRecord?) -> UIViewController?)?
    var generateTeamDetail: ((TeamRecord) -> String?)?
    private var maxNumber: Int = 0
    private var teams: [TeamRecord] = []
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

//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(handleRefreshAction),
//                                               name: .refreshTeams, object: nil)

        self.tableView.allowsSelection = (generateSegueableController != nil)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pInviteCell", for: indexPath) as UITableViewCell
        let team = self.teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.detailTextLabel?.text = generateTeamDetail?(team) ?? ""

        return cell
    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {

            self.semaphore.wait()

            let onSuccess = { (teams: [TeamRecord]) -> Void in
                self.teams = teams
            }

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                self.semaphore.signal()
            }

            let inviteManager = InviteManager(identity: self.identity)
            unwindPagination(manager: inviteManager,
                             startingPage: 1,
                             onSuccess: onSuccess,
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
        }
    }

    @IBAction func acceptInvite(_ sender: Any) {
        print("Accepted!")
    }
    @IBAction func rejectInvite(_ sender: Any) {
        print("Rejected!")
    }
    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
