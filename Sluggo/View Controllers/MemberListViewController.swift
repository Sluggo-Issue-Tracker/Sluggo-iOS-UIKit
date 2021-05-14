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
    private var fetchingMembers: [MemberRecord] = []
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
            switch(result) {
            case .success(let record):
                self.maxNumber = record.count
                
                let pageOffset = (page - 1) * self.identity.pageSize
                if (pageOffset < self.fetchingMembers.count) {
                    self.fetchingMembers.removeSubrange(pageOffset...self.fetchingMembers.count-1)
                }
                
                for entry in record.results {
                    self.fetchingMembers.append(entry)
                }
                
                if (self.fetchingMembers.count >= self.maxNumber) {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                        self.members = Array(self.fetchingMembers)
                        self.fetchingMembers.removeAll()
                        self.tableView.reloadData()
                        self.isFetching = false
                    }
                    return
                } else {
                    self.loadData(page: page + 1)
                }
                
                break;
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
