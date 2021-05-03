//
//  TicketListController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/27/21.
//

import UIKit

class TicketListController: UITableViewController {

    var identity: AppIdentity
    var maxNumber: Int = 0
    var tickets: [TicketRecord] = []
    var isFetching: Bool = false
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    // MARK: initial actions
    override func viewDidLoad() {
        configureRefreshControl()
        loadData(page: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem( barButtonSystemItem: .add, target: self, action: #selector(connectPopUp))
    }
    
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    
    @objc func handleRefreshAction() {
        tickets = []
        self.loadData(page: 1)
    }

    
    // MARK: Table view stuff
    
    // @stephan this is probably where you'll spawn the detail views once you get going on that.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let identity = self.identity
        let detailStoryboard = UIStoryboard(name: "TicketDetail", bundle: nil)
        if let vc = detailStoryboard.instantiateViewController(identifier: "TicketDetail", creator:{ coder in
            return TicketDetailViewController(coder: coder, identity: identity)
        }) as TicketDetailViewController? {
            vc.ticket = tickets[indexPath.row]
            
            self.present(vc, animated: true, completion: nil)
        }
        
        
        
//        let tempStory = UIStoryboard(name: "TicketDetail", bundle: nil)
//        let vc = tempStory.instantiateViewController(identifier: "TicketDetail", creator: { coder in
//            return TicketDetailViewController(coder: coder, identity: self.identity)
//        })
//
//        vc.ticket = tickets[indexPath.row]
//
//        self.present(vc, animated: true, completion: nil)
        
    }
    
    @objc func connectPopUp() {
        let identity = self.identity
        let detailStoryboard = UIStoryboard(name: "TicketDetail", bundle: nil)
        if let vc = detailStoryboard.instantiateViewController(identifier: "TicketDetail", creator:{ coder in
            return TicketDetailViewController(coder: coder, identity: identity)
        }) as TicketDetailViewController? {
            vc.ticket = nil
            self.present(vc, animated: true, completion: nil)
        }
    }
    
//    @IBSegueAction func passToDetail(_ coder: NSCoder, sender: Any?) -> TicketDetailViewController? {
//        print ("Sender Stuff: /n")
//        print(sender)
//        print("Type is")
//        print(sender is UITableViewCell)
//        if(sender is UITableViewCell){
//
//        }
//        return TicketDetailViewController(coder: coder, identity: identity, ticket: nil)
//    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Ticket", for: indexPath) as! TicketTableViewCell
        cell.loadFromTicketRecord(ticket: tickets[indexPath.row])
        
        if (indexPath.row == tickets.count - 1 && tickets.count < maxNumber && !isFetching) {
            DispatchQueue.main.async {
                self.loadData(page: ((indexPath.row + 1) / self.identity.pageSize) + 1)
            }
        }
        
        return cell
    }
    
    // MARK: API calls
    private func loadData(page: Int) {
        let ticketManager = TicketManager(identity)
        isFetching = true
        ticketManager.listTeamTickets(page: page) { result in
            switch(result) {
            case .success(let record):
                self.tickets += record.results
                self.maxNumber = record.count
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                    self.isFetching = false
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
