//
//  HomeTableViewController.swift
//  Sluggo
//
//  Created by Isaac Trimble-Pederson on 5/3/21.
//

import UIKit

class HomeTableViewController: UITableViewController {
    var identity: AppIdentity!
    var tickets: [TicketRecord] = []
    
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
        
        // Load the tickets
        let manager = TicketManager(identity)
        manager.listTeamTickets(page: 1) { result in
            switch(result) {
            case .success(let list):
                DispatchQueue.main.sync {
                    self.tickets = list.results
                    self.tableView.reloadData()
                }
                break;
            case .failure(let error):
                UIAlertController.createAndPresentError(vc: self, error: error, completion: nil)
                print("FAILURE")
            }
        }

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tickets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Ticket", for: indexPath) as! TicketTableViewCell
        let record = tickets[indexPath.row]
        
        cell.loadFromTicketRecord(ticket: record)

        return cell
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
