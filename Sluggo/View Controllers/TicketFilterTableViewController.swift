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
    
    // TODO: wire this shit together
    private let identity = AppIdentity()
    private var assignedUsers: [MemberRecord] = []
    private var ticketTags: [TagRecord] = []
    private var ticketStatuses: [StatusRecord] = []
    private let semaphore = DispatchSemaphore(value: 1)
    private static let numSections = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return TicketFilterTableViewController.numSections
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
    
    // MARK: refresh bullshit
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    
    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()
            
            // this mutex synchronizes the different api calls
            // and access to the completed count
            let mutex = DispatchSemaphore(value: 1)
            var completed = 0
            
            let after = { () -> Void in
                mutex.wait()
                
                completed += 1
                if (completed == TicketFilterTableViewController.numSections) {
                    DispatchQueue.main.async {
                        self.refreshControl?.endRefreshing()
                    }
                    self.semaphore.signal()
                }
                mutex.signal()
            }
            
            let tagManager = TagManager(identity: self.identity)
            UnwindState<TagRecord>.unwindPagination(manager: tagManager,
                             startingPage: 1,
                             onSuccess: { (tags: [TagRecord]) -> Void in
                                self.ticketTags = tags
                             },
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
            
            let statusManger = StatusManager(identity: self.identity)
            UnwindState<StatusRecord>.unwindPagination(manager: statusManger,
                                                       startingPage: 1,
                                                       onSuccess: { (statuses: [StatusRecord]) -> Void in
                                                        self.ticketStatuses = statuses
                                                       },
                                                       onFailure: self.presentErrorFromMainThread,
                                                       after: after)
            
            let memberManager = MemberManager(identity: self.identity)
            UnwindState<MemberRecord>.unwindPagination(manager: memberManager,
                                                       startingPage: 1,
                                                       onSuccess: { (members: [MemberRecord]) -> Void in
                                                            self.assignedUsers = members
                                                       },
                                                       onFailure: self.presentErrorFromMainThread,
                                                       after: after)
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
