//
//  AdminUserRolesTableViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/17/21.
//

import UIKit

class AdminUserRolesTableViewController: UITableViewController {

    var identity: AppIdentity!
    var member: MemberRecord?
    var initialRole: String?
    var role: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBarItems()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        preSelect()
    }

    func configureBarItems() {
        let doneAction = UIAction { _ in
            self.changeMemberRecordRole()
            self.navigationController?.popViewController(animated: true)
        }
        navigationItem.title = "User " + member!.owner.username
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
    }

    func preSelect() {
        if member?.role == "AD" {
            let indexPath = IndexPath(row: 1, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            role = "AD"
            initialRole = "AD"
            // print("Selected AD")
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            role = "AP"
            initialRole = "AP"
            // print("Selected AP")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            role = "AP"
        } else {
            role = "AD"
        }
    }

    func changeMemberRecordRole() {
        if initialRole != role {
            member?.role = role!
            let manager = MemberManager(identity: self.identity)
            manager.updateMemberRecord(member!) { result in
                self.processResult(result: result) { _ in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshMembers, object: self)
                    }
                }
            }
        }
    }

}
