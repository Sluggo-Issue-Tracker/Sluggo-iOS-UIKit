//
//  TicketTabTableViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/16/21.
//

import UIKit

class TicketTabTableViewController: UITableViewController {

    var identity: AppIdentity!
    var completion: (([TagRecord]) -> Void)?
    var selectedTags: [TagRecord] = []

    var ticketTags: [TagRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        configureBarItems()
        loadData()
    }

    func configureBarItems() {
        let doneAction = UIAction { _ in
            self.dismiss(animated: true) {
                self.completion?(self.selectedTags)
            }
        }
        let cancelAction = UIAction { _ in
            self.dismiss(animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .done, primaryAction: doneAction)
        navigationItem.leftBarButtonItem = UIBarButtonItem(systemItem: .cancel, primaryAction: cancelAction)
    }

    func loadData() {

        let tagManager = TagManager(identity: self.identity)
            tagManager.listFromTeams(page: 1) {result in
                self.processResult(result: result, onSuccess: { record in
                    self.ticketTags = []
                    self.ticketTags += record.results
                    print(self.ticketTags)
                    self.tableView.reloadData()
                    self.preselectItems()
                })
            }
    }

    func preselectItems() {
        let objects = Set(selectedTags.map {$0.object_uuid})

        for (count, comparison) in ticketTags.enumerated() {
            if objects.contains(comparison.object_uuid) {
                let indexPath = IndexPath(row: count, section: 0)
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            }
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ticketTags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt
                                indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "TagEntry", for: indexPath)
        cell.textLabel?.text = ticketTags[indexPath.row].getTitle()
        return cell
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        for (count, selected) in selectedTags.enumerated() {
            if selected.object_uuid == ticketTags[indexPath.row].object_uuid {
                selectedTags.remove(at: count)
                break
            }
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Tags"
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTags.append(ticketTags[indexPath.row])
    }
}
