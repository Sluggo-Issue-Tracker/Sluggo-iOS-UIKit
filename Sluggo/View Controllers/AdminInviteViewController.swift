//
//  AdminInviteViewController.swift
//  Sluggo
//
//  Created by Troy Ebert on 5/31/21.
//

import UIKit

class AdminInviteViewController: UITableViewController {
    var identity: AppIdentity!
    private var invites: [TeamInviteRecord] = []
    private var isFetching = false
    private var semaphore = DispatchSemaphore(value: 1)

    required init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }

    required init? (coder: NSCoder) {
        fatalError("Must be initialized with identity")
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
        return invites.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TeamInviteCell", for: indexPath) as UITableViewCell
        let invite = self.invites[indexPath.row]

        cell.textLabel?.text = invite.user_email
        cell.detailTextLabel?.text = ""

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let aCon = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            aCon.addAction(UIAlertAction(title: "Delete Invite", style: .destructive, handler: { _ in
                let manager = TeamInviteManager(identity: self.identity)
                let invite = self.invites[indexPath.row]
                manager.deleteTeamInvite(invite: invite) { result in
                    self.processResult(result: result) { _ in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .refreshTeamInvites, object: self)
                            NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        }
                    }
                }
            }))
            aCon.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            aCon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            present(aCon, animated: true)
        }
    }

    @IBAction func addInvite(_ sender: Any) {
        let aCon = UIAlertController(title: "Invite User", message: nil, preferredStyle: .alert)
        aCon.addTextField { textField in
            textField.placeholder = "User Email"
        }
        aCon.addAction(UIAlertAction(title: "Cancel", style: .cancel))

        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            if aCon.textFields![0].text!.contains(" ") {
                self.presentError(error: Exception.runtimeError(message: "User Email cannot contain any spaces"))
            } else {
                let textField = aCon.textFields?[0] ?? nil
                if let text = textField?.text {
                    let inviteManager = TeamInviteManager(identity: self.identity)
                    let invite = WriteTeamInviteRecord(user_email: text)
                    inviteManager.addTeamInvite(invite: invite) { result in
                        self.processResult(result: result) { _ in
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .refreshTeamInvites, object: self)
                            }
                        }
                    }
                }
            }
        })

        saveAction.isEnabled = false
        // adding the notification observer here

        NotificationCenter.default.addObserver(
            forName: UITextField.textDidChangeNotification,
            object: aCon.textFields?[0],
            queue: OperationQueue.main) { _ in

                let title = aCon.textFields?[0]
                saveAction.isEnabled = !title!.text!.isEmpty
        }

        aCon.addAction(saveAction)

        aCon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(aCon, animated: true)

    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()

            let onSuccess = { (invites: [TeamInviteRecord]) -> Void in
                self.invites = invites
            }

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                self.semaphore.signal()
            }

            let teamInviteManager = TeamInviteManager(identity: self.identity)
            unwindPagination(manager: teamInviteManager, startingPage: 1, onSuccess: onSuccess,
                             onFailure: self.presentErrorFromMainThread, after: after)
        }

    }
}

extension Notification.Name {
    static let refreshTeamInvites = Notification.Name(rawValue: "SLGRefreshTeamInvitesNotification")
}
