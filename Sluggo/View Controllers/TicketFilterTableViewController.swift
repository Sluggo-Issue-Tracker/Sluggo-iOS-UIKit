//
//  TicketFilterTableViewController.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/11/21.
//

import UIKit

enum FilterViewCategories: Int {
    case assignedUsers = 0
    case ticketTags = 1
    case ticketStatuses = 2
}

class TicketFilterTableViewController: UITableViewController {
    
    private let assignedUsers: [UserRecord] = []
    private let ticketTags: [TagRecord] = []
    private let ticketStatuses: [StatusRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch(section) {
        case FilterViewCategories.assignedUsers.rawValue:
            return self.assignedUsers.count
        case FilterViewCategories.ticketTags.rawValue:
            return self.ticketTags.count
        case FilterViewCategories.ticketStatuses.rawValue:
            return self.ticketStatuses.count
        default:
            fatalError("Invalid section count queried")
        }
    }

//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        switch(indexPath.section) {
//        case HomepageCategories.assigned.rawValue:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketTableViewCell
//            cell.loadFromTicketRecord(ticket: assignedTickets[indexPath.row])
//            return cell
//        case HomepageCategories.pinned.rawValue:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell", for: indexPath) as! TicketTableViewCell
//            cell.loadFromTicketRecord(ticket: pinnedTickets[indexPath.row].ticket)
//            return cell
//        case HomepageCategories.tags.rawValue:
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceholderCell")!
//            cell.textLabel?.text = "Not yet implemented."
//            return cell
//        default:
//            fatalError("Accessed section outside of scope, should never occur")
//        }
//    }

}
