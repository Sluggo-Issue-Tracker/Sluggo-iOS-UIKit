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
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var dueDateSwitch: UISwitch!
    
    // MARK: Variables
    var identity: AppIdentity
    var ticket: TicketRecord?
    var pickerView: UIPickerView = UIPickerView()
    var editingTicket = false
   
    var teamMembers: [MemberRecord?] = [nil]
    var currentMember: MemberRecord? = nil
    
    init? (coder: NSCoder, identity: AppIdentity, ticket: TicketRecord?) {
        self.identity = identity
        self.ticket = ticket
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dueDatePicker.isEnabled = dueDateSwitch.isOn
        
        let memberManager = MemberManager(identity: self.identity)
        memberManager.listFromTeams(page: 1) { result in
            self.processResult(result: result, onSuccess: {
                record in
                self.teamMembers = [nil]
                for user in record.results{
                    self.teamMembers.append(user)
                }
            })
        }
        pickerView.dataSource = self
        pickerView.delegate = self
        updateUI()

    }

    func updateUI() {
        
        ticketTitle.text = self.ticket?.title ?? ""
        ticketDescription.text = ticket?.description ?? ""
        assignedField.text = ticket?.assigned_user?.owner.username ?? "No Assigned User"
        dueDatePicker.date = ticket?.due_date ?? Date()
        dueDateSwitch.isEnabled = (ticket?.due_date != nil)
        dueDatePicker.isEnabled = dueDateSwitch.isEnabled
        assignedField.isEnabled = true
        setEditMode(false)
        createUserPicker()
    }
    
    func setEditMode(_ editing: Bool) {
        editingTicket = editing
        ticketTitle.isUserInteractionEnabled = editing
        ticketDescription.isUserInteractionEnabled = editing
        dueDatePicker.isEnabled = true
        dueDatePicker.isUserInteractionEnabled = editing
        dueDateSwitch.isUserInteractionEnabled = editing
        assignedField.isUserInteractionEnabled = editing
        dueDateSwitch.isHidden = !editing
    }
    
    func doSave() {
        let title = ticketTitle.text ?? "Default Title"
        let description = ticketDescription.text
        let date = dueDateSwitch.isOn ? dueDatePicker.date : nil
        let member = currentMember?.id
        
        if editingTicket {
            ticket!.title = title
            ticket!.description = description
            ticket!.due_date = date
            ticket!.assigned_user = currentMember
            
            let manager = TicketManager(identity)
            
            manager.updateTicket(ticket: ticket!) {
                result in
                self.processResult(result: result) {
                    _ in
                    DispatchQueue.main.async {
                        self.setEditMode(false)
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                    }
                }
            }
        }
        else {
            let ticket = WriteTicketRecord(tag_list: [],
                                           assigned_user: member,
                                           status: nil,
                                           title: title,
                                           description: description,
                                           due_date: date)
            let manager = TicketManager(identity)
            manager.makeTicket(ticket: ticket) {
                result in
                self.processResult(result: result) {
                    _ in
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: .refreshTrigger, object: self)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    @IBAction func EditButtonHit(_ sender: Any) {
        if let barButton = sender as? UIBarButtonItem {
            if barButton.title == "Edit" {
                setEditMode(true)
                barButton.title = "Save"
            } else {
                doSave()
                barButton.title = "Edit"
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
        
        //create bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(userPicked))
        toolbar.setItems([doneButton], animated: true)
        assignedField.inputAccessoryView = toolbar
        
        assignedField.inputView = pickerView
    }
    
    @objc func userPicked(){
        assignedField.text = currentMember?.owner.username ?? "No Assigned User"
        self.view.endEditing(true)

    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamMembers.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return teamMembers[row]?.owner.username ?? "No Assigned User"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentMember = teamMembers[row]
    }
    
    
}
