//
//  PendingInvitesViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/30/21.
//

import UIKit

class PendingInvitesViewController: UITableViewController {
    var identity: AppIdentity!
    var generateSegueableController: ((AppIdentity, InviteRecord?) -> UIViewController?)?
    var generateTeamInviteDetail: ((InviteRecord) -> String?)?
    private var maxNumber: Int = 0
    private var inviteeTeams: [InviteRecord] = []
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

        self.tableView.allowsSelection = (generateSegueableController != nil)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteeTeams.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pInviteCell", for: indexPath) as InviteTableCell
        let inviteeTeam = self.inviteeTeams[indexPath.row]
        cell.textLabel?.text = inviteeTeam.team.name
        cell.acceptButton.tag = indexPath.row
        // cell.detailTextLabel?.text = generateTeamInviteDetail?(inviteeTeam) ?? ""

        return cell
    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                self.semaphore.signal()
            }

            let inviteManager = InviteManager(identity: self.identity)
            inviteManager.getInvites { result in
                self.processResult(result: result,
                                   onSuccess: { invites in self.inviteeTeams = invites},
                                   after: after)
            }
        }
    }

    @objc func doAcceptInvitation() {
        print("Accepted!")
    }

    @objc func doRejectInvitation() {
        print("Rejected!")
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

class InviteTableCell: UITableViewCell {

    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
    }
}
