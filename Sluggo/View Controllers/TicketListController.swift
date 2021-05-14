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
    var filterParams: TicketFilterParameters = TicketFilterParameters()

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
        setupMenuBar()
        loadData(page: 1)

        NotificationCenter.default.addObserver(forName: Constants.Signals.TEAM_CHANGE_NOTIFICATION,
                                               object: nil,
                                               queue: nil) { _ in
            self.filterParams = TicketFilterParameters()
            self.handleRefreshAction()
        }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleRefreshAction),
                                               name: .refreshTrigger, object: nil)
    }

    func setupMenuBar() {

        let saveMenu = UIMenu(title: "", children: [
                                UIAction(title: "Create New", image: UIImage(systemName: "plus")) { _ in
                                    self.connectPopUp()
                                },
                                UIAction(title: "Filter", image: UIImage(systemName: "folder")) { _ in
                                    self.launchFilterPopup()
                                }
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem( image: UIImage(systemName: "ellipsis"),
                                                             primaryAction: nil, menu: saveMenu)
    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    @objc func handleRefreshAction() {
        self.loadData(page: 1)
    }

    // MARK: Table view stuff

    // @stephan this is probably where you'll spawn the detail views once you get going on that.
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let identity = self.identity
        let detailStoryboard = UIStoryboard(name: "TicketDetail", bundle: nil)
        if let view = detailStoryboard.instantiateViewController(identifier: "TicketDetail", creator: { coder in
            return TicketDetailTableViewController(coder: coder)
        }) as TicketDetailTableViewController? {
            view.identity = identity
            view.ticket = self.tickets[indexPath.row]
            navigationController?.pushViewController(view, animated: true)
        }
    }

    // MARK: menu item delegates
    func connectPopUp() {
        let detailStoryboard = UIStoryboard(name: "TicketDetail", bundle: nil)
        let view = detailStoryboard.instantiateViewController(identifier: "TicketDetailModal")
        if let child = view.children[0] as? TicketDetailTableViewController {
            child.identity = self.identity
            child.ticket = nil
        }

        self.present(view, animated: true, completion: nil)
    }

    func launchFilterPopup() {
        // launch the view controller holding the filter view
        if let view = storyboard?.instantiateViewController(identifier: "FilterNavigationController") {
            if let child = view.children[0] as? TicketFilterTableViewController {
                child.identity = self.identity
                child.filterParams = self.filterParams
                child.completion = { queryParams in
                    self.filterParams = queryParams
                    self.handleRefreshAction()
                }
            }

            self.present(view, animated: true, completion: nil)
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tickets.count
    }

    // swiftlint:disable force_cast
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Ticket", for: indexPath) as! TicketTableViewCell

        cell.loadFromTicketRecord(ticket: tickets[indexPath.row])

        if indexPath.row == tickets.count - 1 && tickets.count < maxNumber && !isFetching {
            DispatchQueue.main.async {
                self.loadData(page: ((indexPath.row + 1) / self.identity.pageSize) + 1)
            }
        }

        return cell
    }
    // swiftlint:enable force_cast

    // MARK: API calls
    private func loadData(page: Int) {
        let ticketManager = TicketManager(identity)
        isFetching = true
        ticketManager.listTeamTickets(page: page, queryParams: self.filterParams) { result in
            switch result {
            case .success(let record):
                self.maxNumber = record.count

                var ticketsCopy = Array(self.tickets)
                // remove all after starting from the beginning of the first element in this page
                let pageOffset = (page - 1) * self.identity.pageSize
                if pageOffset < self.tickets.count {
                    ticketsCopy.removeSubrange(pageOffset...self.tickets.count-1)
                }

                for entry in record.results {
                    ticketsCopy.append(entry)
                }

                DispatchQueue.main.sync {
                    self.refreshControl?.endRefreshing()
                    self.tickets = ticketsCopy
                    self.tableView.reloadData()
                    self.isFetching = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}

extension Notification.Name {
    static let refreshTrigger = Notification.Name(rawValue: "SLGRefreshTriggerNotification")
}
