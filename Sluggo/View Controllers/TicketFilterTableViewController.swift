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
    
    var identity: AppIdentity!
    var completion: ((TicketFilterParameters) -> Void)?
    var filterParams: TicketFilterParameters!
    
    private var teamMembers: [MemberRecord] = []
    private var ticketTags: [TagRecord] = []
    private var ticketStatuses: [StatusRecord] = []
    private let semaphore = DispatchSemaphore(value: 1)
    private static let numSections = 3
    
    private var sectionSelectedMap = [
        FilterViewCategories.assignedUsers.rawValue: nil,
        FilterViewCategories.ticketTags.rawValue: nil,
        FilterViewCategories.ticketStatuses.rawValue: nil
    ] as [Int: Int?]

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        configureBarItems()
        handleRefreshAction() {
            self.preselectItems()
        }
    }
    
    func configureBarItems() {
        let doneAction = UIAction() { action in
            self.dismiss(animated: true) {
                self.completion?(self.filterParams)
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return TicketFilterTableViewController.numSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch(section){
        case FilterViewCategories.assignedUsers.rawValue:
            return teamMembers.count
        case FilterViewCategories.ticketTags.rawValue:
            return ticketTags.count
        case FilterViewCategories.ticketStatuses.rawValue:
            return ticketStatuses.count
        default:
            fatalError("no such section")
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterEntry", for: indexPath)
        var text = ""
        
        switch(indexPath.section) {
        case FilterViewCategories.assignedUsers.rawValue:
            text = teamMembers[indexPath.row].getTitle()
            break
        case FilterViewCategories.ticketTags.rawValue:
            text = ticketTags[indexPath.row].getTitle()
            break
        case FilterViewCategories.ticketStatuses.rawValue:
            text = ticketStatuses[indexPath.row].getTitle()
            break
        default:
            fatalError("no such section")
        }
        
        cell.textLabel?.text = text
        return cell
    }
    
    // MARK: duplicaty nonsense
    func preselectItems() {
        if let row = self.teamMembers.firstIndex(where: { record in
            record.object_uuid == self.filterParams.assignedUser?.object_uuid
        }) {
            let indexPath = IndexPath(row: row, section: FilterViewCategories.assignedUsers.rawValue)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            sectionSelectedMap[FilterViewCategories.assignedUsers.rawValue] = indexPath.row
        }
        
        if let row = self.ticketStatuses.firstIndex(where: { record in
            record.object_uuid == self.filterParams.ticketStatus?.object_uuid
        }) {
            let indexPath = IndexPath(row: row, section: FilterViewCategories.ticketStatuses.rawValue)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            sectionSelectedMap[FilterViewCategories.ticketStatuses.rawValue] = indexPath.row

        }
        
        if let row = self.ticketTags.firstIndex(where: { record in
            record.object_uuid == self.filterParams.ticketTag?.object_uuid
        }) {
            let indexPath = IndexPath(row: row, section: FilterViewCategories.ticketTags.rawValue)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .top)
            sectionSelectedMap[FilterViewCategories.ticketTags.rawValue] = indexPath.row

        }
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        case FilterViewCategories.assignedUsers.rawValue:
            self.filterParams.assignedUser = nil
        case FilterViewCategories.ticketTags.rawValue:
            self.filterParams.ticketTag = nil
        case FilterViewCategories.ticketStatuses.rawValue:
            self.filterParams.ticketStatus = nil
        default:
            fatalError("no such section")
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.section){
        case FilterViewCategories.assignedUsers.rawValue:
            self.filterParams.assignedUser = self.teamMembers[indexPath.row]
        case FilterViewCategories.ticketTags.rawValue:
            self.filterParams.ticketTag = self.ticketTags[indexPath.row]
        case FilterViewCategories.ticketStatuses.rawValue:
            self.filterParams.ticketStatus = self.ticketStatuses[indexPath.row]
        default:
            fatalError("no such section")
        }

        if let previousInSection = self.sectionSelectedMap[indexPath.section]! {
            tableView.deselectRow(at: IndexPath(row: previousInSection, section: indexPath.section), animated: true)
        }
        
        self.sectionSelectedMap[indexPath.section] = indexPath.row
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case FilterViewCategories.assignedUsers.rawValue:
            return "Members"
        case FilterViewCategories.ticketTags.rawValue:
            return "Tags"
        case FilterViewCategories.ticketStatuses.rawValue:
            return "Statuses"
        default:
            return "Error!"
        }
    }
    
    // MARK: refresh stuff
    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }
    
    @objc func handleRefreshAction(after: (() -> Void)? = nil) {

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
                        self.tableView.reloadData() // we reload all the mf data
                        self.preselectItems()
                    }
                    
                    self.semaphore.signal()
                }
                mutex.signal()
            }
            
            let tagManager = TagManager(identity: self.identity)
            unwindPagination(manager: tagManager,
                             startingPage: 1,
                             onSuccess: { (tags: [TagRecord]) -> Void in
                                self.ticketTags = tags
                             },
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
            
            let statusManger = StatusManager(identity: self.identity)
            unwindPagination(manager: statusManger,
                           startingPage: 1,
                           onSuccess: { (statuses: [StatusRecord]) -> Void in
                            self.ticketStatuses = statuses
                           },
                           onFailure: self.presentErrorFromMainThread,
                           after: after)
            
            let memberManager = MemberManager(identity: self.identity)
            unwindPagination(manager: memberManager,
                             startingPage: 1,
                             onSuccess: { (members: [MemberRecord]) -> Void in
                                self.teamMembers = members
                             },
                             onFailure: self.presentErrorFromMainThread,
                             after: after)
        }
    }


}
