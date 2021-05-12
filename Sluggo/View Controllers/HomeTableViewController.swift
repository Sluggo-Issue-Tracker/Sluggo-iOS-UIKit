//
//  HomeTableViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/3/21.
//

import UIKit

enum HomepageCategories: Int {
    case assigned = 0
    case pinned = 1
    case tags = 2
}

class HomeTableViewController: UITableViewController {
    var identity: AppIdentity!
    var member: MemberRecord!
    var assignedTickets: [TicketRecord] = []
    var pinnedTickets: [PinnedTicketRecord] = []
    
    // Injection for identity
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl?.beginRefreshing()
        // Fetch items and begin populating the table view
        loadMember(completionHandler: refreshContent)
        
        // Setup refresh control
        NotificationCenter.default.addObserver(forName: Constants.Signals.TEAM_CHANGE_NOTIFICATION,
                                               object: nil,
                                               queue: nil) { _ in
            self.refreshContent()
        }
        self.refreshControl?.addTarget(self, action: #selector(refreshContent), for: .valueChanged)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadMember(completionHandler: (() -> Void)?) {
        let memberManager = MemberManager(identity: identity)
        memberManager.getMemberRecord(user: identity.authenticatedUser!, identity: identity) { result in
            self.processResult(result: result, onSuccess: { retrievedMember in
                self.member = retrievedMember
            }, after: completionHandler)
        }
    }
    
    func loadAssignedTickets(completionHandler: (() -> Void)?) {
        // Note: This will only grab the first page.
        // This is an OK assumption, since we assume the total page size is > 3.
        // Ideally, this could be extended with some other endpoints to get the total counts
        // but this will suffice for now
        let ticketsManager = TicketManager(identity)
        let queryParams = TicketFilterParameters(assignedUser: member)
        
        ticketsManager.listTeamTickets(page: 1, queryParams: queryParams) { result in
            self.processResult(result: result, onSuccess: { retrievedAssignedTickets in
                self.assignedTickets = retrievedAssignedTickets.results
                self.tableView.reloadSections([HomepageCategories.assigned.rawValue], with: .automatic)
            }, after: completionHandler)
        }
    }
    
    func loadPinnedTickets(completionHandler: (() -> Void)?) {
        let pinnedTicketsManager = PinnedTicketManager(identity: self.identity, member: self.member)
        pinnedTicketsManager.fetchPinnedTickets() { result in
            self.processResult(result: result, onSuccess: { retrievedPinned in
                self.pinnedTickets = retrievedPinned
                self.tableView.reloadSections([HomepageCategories.pinned.rawValue], with: .automatic)
            }, after: completionHandler)
        }
    }
    
    @objc func refreshContent() {
        // Dispatch to background thread so we don't permanently sleep the main thread
        // This is done since processResult handles closures back on the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            if(self.member == nil) {
                // Not safe to make the call
                // Might make sense to migrate to optionals in data layer
                // for future iterations of the app
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return;
            }
            
            // Setup gating semaphores and variables
            let sem = DispatchSemaphore(value: 0)
            var loadedAssigned = false
            var loadedPinned = false
            
            // Make calls to reload data, with completions to signal semaphore
            self.loadAssignedTickets() {
                loadedAssigned = true
                sem.signal()
            }
            self.loadPinnedTickets() {
                loadedPinned = true
                sem.signal()
            }
            
            // Wait for everything to complete and avoid blocking
            while(!(loadedPinned && loadedAssigned)) {
                sem.wait()
            }
            
            // Stop the refresh control (being careful to dispatch to main thread)
            DispatchQueue.main.async {
                self.refreshControl?.endRefreshing()
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section) {
        case HomepageCategories.assigned.rawValue:
            return self.assignedTickets.count
        case HomepageCategories.pinned.rawValue:
            return self.pinnedTickets.count
        case HomepageCategories.tags.rawValue:
            return 1
        default:
            fatalError("Invalid section count queried")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case HomepageCategories.assigned.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketTableViewCell
            cell.loadFromTicketRecord(ticket: assignedTickets[indexPath.row])
            return cell
        case HomepageCategories.pinned.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketTableViewCell
            cell.loadFromTicketRecord(ticket: pinnedTickets[indexPath.row].ticket)
            return cell
        case HomepageCategories.tags.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")!
            cell.textLabel?.text = "Not yet implemented."
            return cell
        default:
            fatalError("Accessed section outside of scope, should never occur")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case HomepageCategories.assigned.rawValue:
            return "Assigned to You"
        case HomepageCategories.pinned.rawValue:
            return "Pinned Tickets"
        case HomepageCategories.tags.rawValue:
            return "Your Tags"
        default:
            return "Error!"
        }
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let _ = self.tableView(self.tableView, cellForRowAt: indexPath) as? TicketTableViewCell {
//            // Present error
//            let error = Exception.runtimeError(message: "Opening ticket details from Home not yet implemented!")
//            UIAlertController.createAndPresentError(vc: self, error: error) { action in
//                // Deselect row once alert acknowledged
//                tableView.deselectRow(at: indexPath, animated: true)
//            }
//        }
//    }

    @IBSegueAction func gotoTicketDetail(_ coder: NSCoder) -> TicketDetailViewController? {
        let selectedPath = tableView.indexPathForSelectedRow
        switch(selectedPath!.section) {
        case HomepageCategories.assigned.rawValue:
            return TicketDetailViewController(coder: coder, identity: self.identity, ticket: assignedTickets[selectedPath!.row], completion: nil)
        case HomepageCategories.pinned.rawValue:
            return TicketDetailViewController(coder: coder, identity: self.identity, ticket: pinnedTickets[selectedPath!.row].ticket, completion: nil)
        default:
            fatalError("Nothing should be selectable from unimplemented categories!")
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
