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
            let acon = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            acon.addAction(UIAlertAction(title: "Delete Tag", style: .destructive, handler: { _ in
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
            acon.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            acon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
            present(acon, animated: true)
        }
    }

    @IBSegueAction func segueToTagCreate(_ coder: NSCoder) -> AdminTagCreateViewController? {
        let view = AdminTagCreateViewController(coder: coder, identity: identity)
        return view
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

class AdminTagCreateViewController: UITableViewController {
    var identity: AppIdentity!
    @IBOutlet weak var tagTitle: UITextField!

    required init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }

    required init? (coder: NSCoder) {
        fatalError("Must be initialized with identity")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func doneButtonClicked(_ sender: Any) {
        let title = tagTitle.text ?? "Default Tag Title"
        let manager = TagManager(identity: identity)
        let tag = WriteTagRecord(title: title)
        manager.makeTag(tag: tag) { result in
            self.processResult(result: result) { _ in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .refreshTags, object: self)
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
}
