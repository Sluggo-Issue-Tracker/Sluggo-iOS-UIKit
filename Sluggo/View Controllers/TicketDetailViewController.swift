//
//  TicketDetailViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/30/21.
//

import UIKit

//var teamMembers: [String] = ["No Assigned User"]
var teamMembers: [MemberRecord?] = [nil]
var currentMember: MemberRecord? = nil
var currentlyChosenMember: MemberRecord? = nil

class TicketDetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var ticketTitle: UITextField!
    @IBOutlet weak var ticketDescription: UITextView!
    @IBOutlet weak var navigationItemDisplay: UINavigationItem!
    @IBOutlet weak var assignedUserTextField: UITextField!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var ticketTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    @IBOutlet weak var dueDateLabel: UILabel!
    
    var identity: AppIdentity
    var ticket: TicketRecord?
    var pickerView: UIPickerView = UIPickerView()
    var completion: (() ->Void)?
    
    init? (coder: NSCoder, identity: AppIdentity, completion: (() -> Void)?) {
        self.identity = identity
        self.completion = completion
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTimePicker.isEnabled = dueDateSwitch.isOn

        let memberManager = MemberManager(identity: self.identity)
        memberManager.listTeamMembers(){ result in
            switch(result){
            case .success(let record):
                teamMembers = [nil]
                for user in record.results{
                    teamMembers.append(user)
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        
        pickerView.dataSource = self
        pickerView.delegate = self
        createUserPicker()
        
        ticketDescription.delegate = self
        if(ticket != nil){
            ticketTitle.text = ticket?.title
            if let description = ticket?.description{
                if(description != ""){
                    ticketDescription.text = description
                }
                else{   // Placeholder text
                    ticketDescription.text = "Description of ticket"
                    ticketDescription.textColor = .lightGray
                }
            }
            else{   // Placeholder text
                ticketDescription.text = "Description of ticket"
                ticketDescription.textColor = .lightGray
            }
            if(ticket?.assigned_user != nil){
                assignedUserTextField.text = ticket?.assigned_user?.owner.username
                currentlyChosenMember = ticket?.assigned_user
            }
            if let date = ticket?.due_date{
                dateTimePicker.date = date
                dateTimePicker.isEnabled = true
            }
            else{
                dateTimePicker.isHidden = true
                dueDateLabel.isHidden = true
            }
            navBar.isHidden = true
            ticketTitleTopConstraint.constant = 0
            ticketTitle.isUserInteractionEnabled = false
            ticketDescription.isUserInteractionEnabled = false
            dateTimePicker.isUserInteractionEnabled = false
            assignedUserTextField.isUserInteractionEnabled = false
            dueDateSwitch.isHidden = true
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setToEditMode))
        }
        else{
            ticketDescription.text = "Description of ticket"    // Placeholder text
            ticketDescription.textColor = .lightGray
            navigationItemDisplay.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelMode))
            navigationItemDisplay.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitTicketMode))
        }
    }
    
    @IBAction func dueDateSwitch(_ sender: UISwitch) {
        dateTimePicker.isEnabled = sender.isOn
    }

    
    @objc func goBackToPrevView(){
        navigationController?.popViewController(animated: true)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @objc func cancelMode(){
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func submitTicketMode(){
        let title = ticketTitle.text ?? "Default title (This is an error)"
        var description: String?
        description = nil
        if ticketDescription.textColor != .lightGray {
            description = ticketDescription.text
        }
        let date = dueDateSwitch.isOn ? dateTimePicker.date : nil
        var member: String?
        member = currentMember?.id
        
        
        let ticket = WriteTicketRecord(tag_list: nil, assigned_user: member, status: nil, title: title, description: description, due_date: date)
        let manager = TicketManager(identity)
        manager.makeTicket(ticket: ticket){ result in
            switch(result){
            case .success(_):
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: self.completion)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func setToEditMode(){
        
    }
    
    func createUserPicker() {
        //create toolbar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35))
        toolbar.sizeToFit()
        toolbar.translatesAutoresizingMaskIntoConstraints = false
        
        //create bar button
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(userPicked))
        toolbar.setItems([doneButton], animated: true)
        assignedUserTextField.inputAccessoryView = toolbar
        
        assignedUserTextField.inputView = pickerView
    }
    
    @objc func userPicked(){
        assignedUserTextField.text = currentMember?.owner.username ?? "No Assigned User"
        self.view.endEditing(true)

    }
    
    // MARK: Placeholder text for description
    // Whoever decided to code UITextView deserves to be beaten
    func textViewDidBeginEditing (_ textView: UITextView) {
        if ticketDescription.textColor == .lightGray{
            ticketDescription.text = nil
            ticketDescription.textColor = .black
        }
    }

    func textViewDidEndEditing (_ textView: UITextView) {
        if ticketDescription.text.isEmpty || ticketDescription.text == "" {
            ticketDescription.textColor = .lightGray
            ticketDescription.text = "Description of Ticket"
        }
    }
}

//MARK: UIPickerView manager

extension TicketDetailViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
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
