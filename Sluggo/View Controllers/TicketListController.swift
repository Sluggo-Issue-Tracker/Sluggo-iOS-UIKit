//
//  TicketListController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/27/21.
//

import UIKit

class TicketListController: UITableViewController {

    
    var identity: AppIdentity
    var tickets: [TicketRecord]
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        self.tickets = []
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadData()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Ticket", for: indexPath) as! TicketTableViewCell
//        cell.titleLabel.text = tickets[indexPath.row].title.capitalized
//        cell.assignedLabel.text = tickets[indexPath.row].assigned_user?.owner.email
        return cell
    }
    
    private func loadData() {
        let ticketManager = TicketManager(identity)
        ticketManager.listTeamTickets() { result in
            switch(result) {
            case .success(let record):
                print("Successful login and retrieved tickets")
                self.tickets = record.results
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
