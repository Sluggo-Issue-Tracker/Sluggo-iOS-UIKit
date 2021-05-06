//
//  TeamTableViewController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/3/21.
//

import UIKit

class TeamTableViewController: UITableViewController {
    var identity: AppIdentity!
    var completion: ((TeamRecord) -> Void)?
    private var maxNumber: Int = 0
    private var fetchingTeams: [TeamRecord] = []
    private var teams: [TeamRecord] = []
    private let semaphore = DispatchSemaphore(value: 1)
    
    override func viewDidLoad() {
        self.configureRefreshControl()
        DispatchQueue.global().async {
            self.handleRefreshAction()
        }
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    

    
    private func preselectRow() {
        if (teams.count == 0) { return }
        
        for i in 0...teams.count-1 {
            let team = teams[i]
            let indexPath = IndexPath(row: i, section: 0)
            if team == self.identity.team {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.completion?(self.teams[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SLGSidebarCell", for: indexPath) as UITableViewCell
        let team = self.teams[indexPath.row]
        cell.textLabel?.text = team.name
        cell.accessoryType = (team == self.identity.team) ? .checkmark : .none
        
        return cell
    }
    
    @objc func handleRefreshAction() {
        // enter the critical section
        self.semaphore.wait()
        self.loadData(page: 1)
    }
    
    private func loadData(page: Int) {
        let teamManager = TeamManager(identity: identity)
        teamManager.listUserTeams(page: page) { result in
            switch(result) {
            case .success(let record):
                self.maxNumber = record.count
                
                let pageOffset = (page - 1) * self.identity.pageSize
                if (pageOffset < self.fetchingTeams.count) {
                    self.fetchingTeams.removeSubrange(pageOffset...self.fetchingTeams.count-1)
                }
                
                for entry in record.results {
                    self.fetchingTeams.append(entry)
                }
                
                if (self.fetchingTeams.count >= self.maxNumber) {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                        self.teams = Array(self.fetchingTeams)
                        self.fetchingTeams.removeAll()
                        self.tableView.reloadData()
                        self.preselectRow()
                    }
                    self.semaphore.signal()
                    return
                } else {
                    self.loadData(page: page + 1)
                }
                
                break;
            case .failure(let error):
                self.semaphore.signal()
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
