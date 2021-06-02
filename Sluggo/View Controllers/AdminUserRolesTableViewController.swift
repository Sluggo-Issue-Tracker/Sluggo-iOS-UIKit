//
//  AdminUserRolesTableViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/17/21.
//

import UIKit

enum MemberRoleCategories: String {
    case admin = "AD"
    case approved = "AP"
    case invited = "IN"// Invited added for adding users to teams
}

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
        if member?.role == MemberRoleCategories.admin.rawValue {
            let indexPath = IndexPath(row: 1, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            role = MemberRoleCategories.admin.rawValue
            initialRole = MemberRoleCategories.admin.rawValue
            // print("Selected AD")
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            role = MemberRoleCategories.approved.rawValue
            initialRole = MemberRoleCategories.approved.rawValue
            // print("Selected AP")
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            role =  MemberRoleCategories.approved.rawValue
        } else {
            role = MemberRoleCategories.admin.rawValue
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
