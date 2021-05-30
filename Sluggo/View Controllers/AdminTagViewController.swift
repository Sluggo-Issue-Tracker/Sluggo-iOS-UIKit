//
//  AdminTagViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/26/21.
//

import UIKit

class AdminTagViewController: UITableViewController {
    var identity: AppIdentity!
    private var tags: [TagRecord] = []
    private var isFetching = false
    private var semaphore = DispatchSemaphore(value: 1)

    required init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }

    required init? (coder: NSCoder) {
        fatalError("Must be initialized with identity")
    }

    override func viewDidLoad() {
        self.configureRefreshControl()
        self.handleRefreshAction()
        NotificationCenter.default.addObserver(self, selector: #selector(handleRefreshAction),
                                               name: .refreshTags, object: nil)

    }

    func configureRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(handleRefreshAction), for: .valueChanged)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tags.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TagCell", for: indexPath) as UITableViewCell
        let tag = self.tags[indexPath.row]
        cell.textLabel?.text = tag.title
        cell.detailTextLabel?.text = ""

        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                            forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let aCon = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            aCon.addAction(UIAlertAction(title: "Delete Tag", style: .destructive, handler: { _ in
                let manager = TagManager(identity: self.identity)
                let tag = self.tags[indexPath.row]
                manager.deleteTag(tag: tag) { result in
                    self.processResult(result: result) { _ in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .refreshTags, object: self)
                            NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        }
                    }
                }
            }))
            aCon.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            aCon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            present(aCon, animated: true)
        }
    }

    @IBAction func addTagHit(_ sender: Any) {
        let aCon = UIAlertController(title: "Create a Tag", message: nil, preferredStyle: .alert)
        aCon.addTextField { textField in
            textField.placeholder = "Enter Tag Title"
        }
        aCon.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { _ in
            let textField = aCon.textFields?[0] ?? nil
            if let text = textField?.text {
                let manager = TagManager(identity: self.identity)
                let tag = WriteTagRecord(title: text)
                manager.makeTag(tag: tag) { result in
                    self.processResult(result: result) { _ in
                        DispatchQueue.main.async {
                            NotificationCenter.default.post(name: .refreshTags, object: self)
                        }
                    }
                }
            }
        })

        saveAction.enabled = false
        // adding the notification observer here
        NSNotificationCenter.defaultCenter().addObserverForName(UITextFieldTextDidChangeNotification, object:aCon.textFields?[0],
            queue: NSOperationQueue.mainQueue()) { notification in

                let title = aCon.textFields?[0] as! UITextField
                saveAction.enabled = !title.text.isEmpty
        }
        
        aCon.addAction(saveAction)

        aCon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(aCon, animated: true)

    }

    @objc func handleRefreshAction() {

        DispatchQueue.global(qos: .userInitiated).async {
            self.semaphore.wait()

            let onSuccess = { (tags: [TagRecord]) -> Void in
                self.tags = tags
            }

            let after = { () -> Void in
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
                self.semaphore.signal()
            }

            let tagManager = TagManager(identity: self.identity)
            unwindPagination(manager: tagManager, startingPage: 1, onSuccess: onSuccess,
                             onFailure: self.presentErrorFromMainThread, after: after)
        }

    }
}

extension Notification.Name {
    static let refreshTags = Notification.Name(rawValue: "SLGRefreshTagsNotification")
}
