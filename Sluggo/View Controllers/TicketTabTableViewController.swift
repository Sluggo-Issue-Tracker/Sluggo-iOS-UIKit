//
//  TicketTabTableViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/16/21.
//

import UIKit

class TicketTabTableViewController: UITableViewController {

    var identity: AppIdentity!
    var completion: (([TagRecord?]) -> Void)?
    var selectedTags: [TagRecord?] = [nil]

    var ticketTags: [TagRecord?] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBarItems()
        loadData()
    }

    func configureBarItems() {
        let doneAction = UIAction {_ in
            self.dismiss(animated: true) {
                self.completion?(self.selectedTags)
            }
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
    }

    func loadData() {

        let tagManager = TagManager(identity: self.identity)
            tagManager.listFromTeams(page: 1) {result in
                self.processResult(result: result, onSuccess: { record in
                    self.ticketTags = []
                    for tag in record.results {
                        self.ticketTags.append(tag)
                        print(tag)
                    }
                    self.tableView.reloadData()
                })
            }
    }

    func preselectItems() {

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("I am here. The count is: ")
        print(ticketTags.count)
        return ticketTags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt
                                indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TagEntry", for: indexPath)
        let text = ticketTags[indexPath.row]!.getTitle()
        cell.textLabel?.text = text
        return cell
    }
}
