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
    private var isFetching: Bool = false
    private var maxNumber: Int = 0
    private var teams: [TeamRecord] = []
    
    override func viewDidLoad() {
        self.configureRefreshControl()
        self.loadData(page: 1)
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    
    @objc func handleRefreshAction() {
        teams = []
        self.loadData(page: 1)
    }
    
    private func preselectRow() {
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
    
    // MARK: API calls
    private func loadData(page: Int) {
        let teamManager = TeamManager(identity: identity)
        teamManager.listUserTeams(page: page) { result in
            switch(result) {
            case .success(let record):
                self.teams += record.results
                self.maxNumber = record.count
                
                DispatchQueue.main.async {
                    if (self.teams.count >= self.maxNumber) {
                        self.refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                        self.isFetching = false
                        self.preselectRow()
                    } else {
                        self.loadData(page: page + 1)
                    }
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
