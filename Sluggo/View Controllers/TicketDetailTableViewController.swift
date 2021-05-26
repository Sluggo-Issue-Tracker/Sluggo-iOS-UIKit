//
//  TicketDetailTableViewController.swift
//  Sluggo
//
//  Created by Andrew Gavgavian on 5/12/21.
//

import UIKit

class TicketDetailTableViewController: UITableViewController {

    // MARK: Outlets
    @IBOutlet var ticketTitle: UITextField!
    @IBOutlet var ticketDescription: UITextView!
    @IBOutlet var assignedField: UITextField!
    @IBOutlet var statusField: UITextField!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagPlusButton: UIButton!
    @IBOutlet var dueDateSwitch: UISwitch!
    @IBOutlet var dueDateLabel: UILabel!
    @IBOutlet var navBar: UINavigationItem!
    @IBOutlet var rightButton: UIBarButtonItem!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var pinTicketButton: UIButton!

    // MARK: Variables
    var identity: AppIdentity!
    var member: MemberRecord!
    var ticket: TicketRecord?
    var pinnedTicket: PinnedTicketRecord?
    var pickerView: UIPickerView = UIPickerView()
    var statusPicker: UIPickerView = UIPickerView()
    var editingTicket = false

    var teamMembers: [MemberRecord?] = [nil]
    var statuses: [StatusRecord?] = [nil]
    var currentMember: MemberRecord?
    var currentStatus: StatusRecord?
    var selectedTags: [TagRecord] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        dueDatePicker.isEnabled = dueDateSwitch.isOn

        let memberManager = MemberManager(identity: self.identity)
        memberManager.listFromTeams(page: 1) { result in
            self.processResult(result: result, onSuccess: { record in
                self.teamMembers = [nil]
                self.teamMembers += record.results
                self.member = self.teamMembers.filter { $0?.owner.id == self.identity.authenticatedUser?.pk }[0]
                if let ticket = self.ticket {
                    let pinnedManager = PinnedTicketManager(identity: self.identity, member: self.member)
                    pinnedManager.fetchPinned(ticket: ticket) { result in
                        self.processResult(result: result, onSuccess: { record in
                            self.pinnedTicket = record
                        }, onError: { _ in
                            self.pinnedTicket = nil
                        }, after: {
                            let title = self.pinnedTicket != nil ? "Un-pin Ticket" : "Pin Ticket"
                            self.pinTicketButton.setTitle(title, for: .normal)
                        })
                    }
                }
            })
        }

        let statusManager = StatusManager(identity: self.identity)
        statusManager.listFromTeams(page: 1) {result in
            self.processResult(result: result, onSuccess: { record in
                self.statuses = [nil]
                self.statuses += record.results
            })
        }

        self.selectedTags = self.ticket?.tag_list ??  []

        refreshTagLabel()

        pickerView.dataSource = self
        pickerView.delegate = self

        statusPicker.dataSource = self
        statusPicker.delegate = self

        pickerView.tag = 1
        statusPicker.tag = 2
        updateUI()

    }

    @IBAction func addTagButtonHit(_ sender: Any) {
        // launch the view controller holding the tag view
        if let view = storyboard?.instantiateViewController(identifier: "TagNavigationController") {
            if let child = view.children[0] as? TicketTabTableViewController {
                child.identity = self.identity
                child.selectedTags = self.selectedTags
                child.completion = { newTags in
                    self.selectedTags = newTags
                    self.refreshTagLabel()
                }
            }
            self.present(view, animated: true, completion: nil)
        }
    }

    func refreshTagLabel() {
        if selectedTags.count == 0 {
            tagLabel.text = "No Tags Selected"
        } else {
            tagLabel.text = selectedTags.map({$0.title}).joined(separator: ", ")
        }
    }

    func updateUI() {

        ticketTitle.text = self.ticket?.title ?? ""
        ticketDescription.text = ticket?.description ?? ""
        assignedField.text = ticket?.assigned_user?.owner.username ?? "No Assigned User"
        statusField.text = ticket?.status?.title ?? "No Status Selected"
        currentMember = ticket?.assigned_user ?? nil
        currentStatus = ticket?.status ?? nil
        dueDatePicker.date = ticket?.due_date ?? Date()
        dueDatePicker.isHidden = (ticket?.due_date == nil)
        dueDateLabel.isHidden = (ticket?.due_date != nil)
        dueDateSwitch.isEnabled = (ticket?.due_date != nil)
        dueDatePicker.isEnabled = dueDateSwitch.isEnabled
        assignedField.isEnabled = true
        navBar.title = self.ticket != nil ? "Selected Ticket" : "Create a Ticket"
        rightButton.title = (self.ticket != nil) ? "Edit" : "Done"

        setEditMode(self.ticket == nil)
        createUserPicker()
        createStatusPicker()
    }

    func setEditMode(_ editing: Bool) {
        editingTicket = editing
        ticketTitle.isUserInteractionEnabled = editing
        ticketDescription.isUserInteractionEnabled = editing
        dueDatePicker.isEnabled = true
        dueDateSwitch.isEnabled = true
        dueDateSwitch.isOn = (ticket?.due_date != nil)
        dueDatePicker.isUserInteractionEnabled = editing
        dueDateSwitch.isUserInteractionEnabled = editing
        assignedField.isUserInteractionEnabled = editing
        statusField.isUserInteractionEnabled = editing
        dueDateSwitch.isHidden = !editing
        dueDatePicker.isHidden = (ticket?.due_date == nil && !editing)
        dueDateLabel.isHidden = (ticket?.due_date != nil || editing)
        tagPlusButton.isHidden = !editing
        tableView.reloadData()
        if editing {
            ticketTitle.becomeFirstResponder()
        }
    }

    func doSave() {
        let title = ticketTitle.text ?? "Default Title"
        let description = ticketDescription.text
        let date = dueDateSwitch.isOn ? dueDatePicker.date : nil
        let member = currentMember?.id
        let status = currentStatus?.id
        let tags = selectedTags.map({$0.id})

        let manager = TicketManager(identity)

        if editingTicket {
            ticket!.title = title
            ticket!.description = description
            ticket!.due_date = date
            ticket!.assigned_user = currentMember
            ticket!.status = currentStatus
            ticket!.tag_list = selectedTags

            manager.updateTicket(ticket: ticket!) { result in
                self.processResult(result: result) { _ in
                    DispatchQueue.main.async {
                        self.setEditMode(false)
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                    }
                }
            }
        } else {
            let ticket = WriteTicketRecord(tag_list: tags,
                                           assigned_user: member,
                                           status: status,
                                           title: title,
                                           description: description,
                                           due_date: date)
            manager.makeTicket(ticket: ticket) { result in
                self.processResult(result: result) { _ in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }

    @IBAction func editButtonHit(_ sender: Any) {
        if let barButton = sender as? UIBarButtonItem {
            if barButton.title == "Edit" {
                setEditMode(true)
                barButton.title = "Save"
            } else if barButton.title == "Save" {
                doSave()
                barButton.title = "Edit"
            } else {
                editingTicket = false
                doSave()
            }
        }
    }

    @IBAction func deleteButtonHit(_ sender: Any) {
        let acon = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        acon.addAction(UIAlertAction(title: "Delete Ticket", style: .destructive, handler: doDeleteTicket))
        acon.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        acon.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
        present(acon, animated: true)
    }

    func doDeleteTicket(action: UIAlertAction) {
        let manager = TicketManager(identity)
        if let ticket = self.ticket {
            manager.deleteTicket(ticket: ticket) { result in
                self.processResult(result: result) { _ in
                    DispatchQueue.main.async {
                        self.setEditMode(false)
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        self.navigationController?.popViewController(animated: false)
                    }
                }
            }
        }
    }
    @IBAction func pinTicketHit(_ sender: Any) {

        let manager = PinnedTicketManager(identity: identity, member: self.member)
        if let pinned = pinnedTicket {
            manager.deletePinnedTicket(pinned: pinned) { result in
                self.processResult(result: result) { _ in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        self.pinTicketButton.setTitle("Pin Ticket", for: .normal)
                        self.pinnedTicket = nil
                    }
                }

            }
        } else {
            manager.postPinnedTicket(ticket: self.ticket!) { result in
                self.processResult(result: result) { record in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        self.pinTicketButton.setTitle("Un-pin Ticket", for: .normal)
                        self.pinnedTicket = record
                    }
                }
            }
        }
    }
}

extension TicketDetailTableViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func createUserPicker() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        // create bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(userPicked))
        toolbar.setItems([doneButton], animated: true)
        assignedField.inputAccessoryView = toolbar

        assignedField.inputView = pickerView
    }

    func createStatusPicker() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false

        // create bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(statusPicked))
        toolbar.setItems([doneButton], animated: true)
        statusField.inputAccessoryView = toolbar

        statusField.inputView = statusPicker
    }

    @objc func userPicked() {
        assignedField.text = currentMember?.owner.username ?? "No Assigned User"
        self.view.endEditing(true)

    }

    @objc func statusPicked() {
        statusField.text = currentStatus?.title ?? "No Status Selected"
        self.view.endEditing(true)
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerView.tag == 1 ? teamMembers.count : statuses.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return teamMembers[row]?.owner.username ?? "No Assigned User"
        } else {
            return statuses[row]?.title ?? "No Status Selected"
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            currentMember = teamMembers[row]
        } else {
            currentStatus = statuses[row]
        }
    }

}

extension TicketDetailTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 6:
            return self.ticket != nil ? 1 : 0
        case 7:
            return (self.editingTicket && self.ticket != nil) ? 1 : 0
        default:
            return 1
        }
    }
}
