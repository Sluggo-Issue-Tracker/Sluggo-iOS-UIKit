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
    @IBOutlet var assignedLabel: UILabel!
    @IBOutlet var dueDatePicker: UIDatePicker!
    @IBOutlet var dueDateSwitch: UISwitch!
    
    // MARK: Variables
    var identity: AppIdentity
    var ticket: TicketRecord?
    var completion: (() ->Void)?
    var pickerView: UIPickerView = UIPickerView()
    var editingTicket = false
   
    var teamMembers: [MemberRecord?] = [nil]
    var currentMember: MemberRecord? = nil
    
    init? (coder: NSCoder, identity: AppIdentity, ticket: TicketRecord?, completion: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
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
        memberManager.listTeamMembers(){ result in
            switch(result){
            case .success(let record):
                self.teamMembers = [nil]
                for user in record.results{
                    self.teamMembers.append(user)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        updateUI()

    }

    func updateUI() {
        
        ticketTitle.text = self.ticket?.title ?? ""
        ticketDescription.text = ticket?.description ?? ""
        assignedLabel.text = ticket?.assigned_user?.owner.username ?? "No Assigned User"
        dueDatePicker.date = ticket?.due_date ?? Date()
        dueDateSwitch.isEnabled = (ticket?.due_date != nil)
        dueDatePicker.isEnabled = dueDateSwitch.isEnabled
    }
    

}
