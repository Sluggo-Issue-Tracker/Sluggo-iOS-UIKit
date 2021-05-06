//
//  HomeTableViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/3/21.
//

import UIKit

class HomeTableViewController: UITableViewController {
    var identity: AppIdentity!
    var member: MemberRecord!
    var pinnedTickets: [PinnedTicket] = []
    var assignedTickets: [TicketRecord] = []
    
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
        
        // Fetch items and begin populating the table view
        loadMember() {
            self.loadAssignedTickets() {
                self.loadPinnedTickets(completionHandler: nil)
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func loadMember(completionHandler: (() -> Void)?) {
        let memberManager = MemberManager(identity: identity)
        memberManager.getMemberRecord(user: identity.authenticatedUser!, identity: identity) { result in
            switch(result) {
            case .success(let member):
                DispatchQueue.main.sync {
                    self.member = member
                    completionHandler?()
                }
                break
            case .failure(let error):
                DispatchQueue.main.async {
                    UIAlertController.createAndPresentError(vc: self, error: error, completion: nil)
                }
            }
        }
    }
    
    func loadAssignedTickets(completionHandler: (() -> Void)?) {
        // TODO
        completionHandler?()
    }
    
    func loadPinnedTickets(completionHandler: (() -> Void)?) {
        let pinnedTicketsManager = PinnedTicketManager(identity: self.identity, member: self.member)
        pinnedTicketsManager.fetchPinnedTickets() { result in
            switch(result) {
            case .success(let pinnedTickets):
                DispatchQueue.main.sync {
                    self.pinnedTickets = pinnedTickets
                    self.tableView.reloadData()
                }
                completionHandler?()
                break
            case .failure(let error):
                DispatchQueue.main.sync {
                    UIAlertController.createAndPresentError(vc: self, error: error, completion: nil)
                }
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
        case 0:
            return 1
        case 1:
            return self.pinnedTickets.count
        case 2:
            return 1
        default:
            fatalError("Invalid section count queried")
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch(indexPath.section) {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")!
            cell.textLabel?.text = "Not yet implemented."
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketTableViewCell
            cell.loadFromTicketRecord(ticket: pinnedTickets[indexPath.row].ticket)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")!
            cell.textLabel?.text = "Not yet implemented."
            return cell
        default:
            fatalError("Accessed section outside of scope, should never occur")
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Assigned to You"
        case 1:
            return "Pinned Tickets"
        case 2:
            return "Your Tags"
        default:
            return "Error!"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let _ = self.tableView(self.tableView, cellForRowAt: indexPath) as? TicketTableViewCell {
            // Present error
            let error = Exception.runtimeError(message: "Opening ticket details from Home not yet implemented!")
            UIAlertController.createAndPresentError(vc: self, error: error) { action in
                // Deselect row once alert acknowledged
                tableView.deselectRow(at: indexPath, animated: true)
            }
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
