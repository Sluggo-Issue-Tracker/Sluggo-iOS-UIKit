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
            NotificationCenter.default.post(name: .refreshMembers, object: self)
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshContent),
                                               name: .refreshTrigger, object: nil)
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
        pinnedTicketsManager.fetchPinnedTickets { result in
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
            if self.member == nil {
                // Not safe to make the call
                // Might make sense to migrate to optionals in data layer
                // for future iterations of the app
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                }
                return
            }

            // Setup gating semaphores and variables
            let sem = DispatchSemaphore(value: 0)
            var loadedAssigned = false
            var loadedPinned = false

            // Check if member matches team, if not, reload the member
            // Use a semaphore to gate flow
            if !self.identity.team!.isMemberInTeam(memberRecord: self.member) {
                self.loadMember {
                    sem.signal()
                }
                sem.wait()
            }

            // Make calls to reload data, with completions to signal semaphore
            self.loadAssignedTickets {
                loadedAssigned = true
                sem.signal()
            }
            self.loadPinnedTickets {
                loadedPinned = true
                sem.signal()
            }

            // Wait for everything to complete and avoid blocking
            while !(loadedPinned && loadedAssigned) {
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
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case HomepageCategories.assigned.rawValue:
            return self.assignedTickets.count
        case HomepageCategories.pinned.rawValue:
            return self.pinnedTickets.count
        default:
            fatalError("Invalid section count queried")
        }
    }
    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case HomepageCategories.assigned.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell",
                                                     for: indexPath) as! TicketTableViewCell
            cell.loadFromTicketRecord(ticket: assignedTickets[indexPath.row])
            return cell
        case HomepageCategories.pinned.rawValue:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TicketCell",
                                                     for: indexPath) as! TicketTableViewCell
            cell.loadFromTicketRecord(ticket: pinnedTickets[indexPath.row].ticket)
            return cell
        default:
            fatalError("Accessed section outside of scope, should never occur")
        }
    }
    // swiftlint:enable force_cast
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case HomepageCategories.assigned.rawValue:
            return "Assigned to You"
        case HomepageCategories.pinned.rawValue:
            return "Pinned Tickets"
        default:
            return "Error!"
        }
    }

    @IBSegueAction func gotoTicketDetail(_ coder: NSCoder) -> TicketDetailTableViewController? {
        let selectedPath = tableView.indexPathForSelectedRow
        switch selectedPath!.section {
        case HomepageCategories.assigned.rawValue:
            let view = TicketDetailTableViewController(coder: coder)
            view!.identity = self.identity
            view!.ticket = assignedTickets[selectedPath!.row]
            return view
        case HomepageCategories.pinned.rawValue:
            let view = TicketDetailTableViewController(coder: coder)
            view!.identity = self.identity
            view!.ticket = pinnedTickets[selectedPath!.row].ticket
            return view
        default:
            fatalError("Nothing should be selectable from unimplemented categories!")
        }
    }
}
