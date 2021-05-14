//
//  MemberList.swift
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
        
        //cell.accessoryType = (member.owner.id == self.identity.authenticatedUser!.pk) ? .checkmark : .none
        
        return cell
    }
    
    
    @objc func handleRefreshAction() {
        // enter the critical section
        // do not wait
        if (isFetching) { return }
        
        isFetching = true
        self.loadData(page: 1)
    }
    
    private func loadData(page: Int) {
        let memberManager = MemberManager(identity: identity)
        
        memberManager.listTeamMembers() { result in
            self.processResult(result: result, onSuccess: { record in
                self.maxNumber = record.count
            
                var membersCopy = Array(self.members)
                let pageOffset = (page - 1) * self.identity.pageSize
                
                if (pageOffset < self.members.count) {
                    membersCopy.removeSubrange(pageOffset...self.members.count-1)
                }
                
                for entry in record.results {
                    membersCopy.append(entry)
                }
            
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.members = membersCopy
                    self.tableView.reloadData()
                    self.isFetching = false
                }
            }, onError: { error in
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }, after: nil)
        }
    }
}
