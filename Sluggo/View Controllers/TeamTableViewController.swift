//
//  TeamTableViewController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/3/21.
//

import UIKit

class TeamTableViewController: UITableViewController {
    private var identity: AppIdentity
    private var completion: (() -> Void)?
    private var teams: [TeamRecord] = []
    
    init? (coder: NSCoder, identity: AppIdentity, completion: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be called w/ identity")
    }
    
    override func viewDidLoad() {
        let teamManager = TeamManager(identity: self.identity)
        
        teamManager.listUserTeams() { result in
            switch result {
            case .success(let teams):
                print("success!")
                DispatchQueue.main.sync { // TODO: handle pagination
                    self.teams = teams.results
                    self.tableView.reloadData()
                }
                break
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.identity.team = self.teams[indexPath.row]
        self.dismiss(animated: true, completion: self.completion)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teams.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Team", for: indexPath) as UITableViewCell
        cell.textLabel?.text = self.teams[indexPath.row].name
        return cell
    }
    
}
