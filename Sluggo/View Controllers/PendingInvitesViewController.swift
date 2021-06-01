//
//  PendingInvitesViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/30/21.
//

import UIKit

class PendingInvitesViewController: UITableViewController {
    var identity: AppIdentity!
    var generateSegueableController: ((AppIdentity, UserInviteRecord?) -> UIViewController?)?
    var generateTeamInviteDetail: ((UserInviteRecord) -> String?)?
    private var maxNumber: Int = 0
    private var inviteeTeams: [UserInviteRecord] = []
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "pInviteCell", for: indexPath)
                as? InviteTableCell else {fatalError("Could not load InviteTableCell")}
        let inviteeTeam = self.inviteeTeams[indexPath.row]
        cell.textLabel?.text = inviteeTeam.team.name
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(doAcceptInvitation(sender:)), for: .touchUpInside)
        cell.rejectButton.tag = indexPath.row
        cell.rejectButton.addTarget(self, action: #selector(doRejectInvitation(sender:)), for: .touchUpInside)

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
            inviteManager.getUserInvites { result in
                self.processResult(result: result,
                                   onSuccess: { invites in self.inviteeTeams = invites},
                                   after: after)
            }
        }
    }

    @objc func doAcceptInvitation(sender: UIButton) {
        let buttonTag = sender.tag

        let invite = self.inviteeTeams[buttonTag]
        let inviteManager = InviteManager(identity: self.identity)
        inviteManager.acceptUserInvite(invite: invite) { result in
            self.processResult(result: result) { _ in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .refreshTrigger, object: self)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }

    @objc func doRejectInvitation(sender: UIButton) {
        let buttonTag = sender.tag

        let invite = self.inviteeTeams[buttonTag]
        let inviteManager = InviteManager(identity: self.identity)
        inviteManager.rejectUserInvite(invite: invite) { result in
            self.processResult(result: result) { _ in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .refreshTrigger, object: self)
                    self.navigationController?.popViewController(animated: false)
                }
            }
        }
    }

    @IBAction func backButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: Invite Table Cell
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
