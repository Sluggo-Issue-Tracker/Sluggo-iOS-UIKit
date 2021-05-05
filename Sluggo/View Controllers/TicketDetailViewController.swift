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
    @IBOutlet weak var currentAssignedUserLabel: UILabel!
    @IBOutlet weak var navigationItemDisplay: UINavigationItem!
    @IBOutlet weak var dateTimePicker: UIDatePicker!
    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var changeButton: UIButton!
    @IBOutlet weak var ticketTitleTopConstraint: NSLayoutConstraint!
    
    var identity: AppIdentity
    var ticket: TicketRecord?
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let memberManager = MemberManager(identity: self.identity)
        memberManager.listTeamMembers(){ result in
            switch(result){
            case .success(let record):
                teamMembers = [nil]
                for user in record.results{
                    teamMembers.append(user)
                }
                // print (record)

            case .failure(let error):
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(changeLabel), name: .changeAssignedUser, object: nil)
        
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
                currentAssignedUserLabel.text = ticket?.assigned_user?.owner.username
                currentlyChosenMember = ticket?.assigned_user
            }
            if let date = ticket?.due_date{
                dateTimePicker.date = date
            }
            //navigationController?.setNavigationBarHidden(true, animated: true)
            navBar.isHidden = true
            ticketTitleTopConstraint.constant = 0
            changeButton.isHidden = true
            ticketTitle.isUserInteractionEnabled = false
            ticketDescription.isUserInteractionEnabled = false
            dateTimePicker.isUserInteractionEnabled = false
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setToEditMode))
        }
        else{
            ticketDescription.text = "Description of ticket"    // Placeholder text
            ticketDescription.textColor = .lightGray
            navigationItemDisplay.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelMode))
            navigationItemDisplay.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(submitTicketMode))
        }
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
        let date = dateTimePicker.date
        
        
        let ticket = WriteTicketRecord(tag_list: nil, assigned_user: currentMember, status: nil, title: title, description: description, due_date: date)
        //print (ticket)
        let manager = TicketManager(identity)
        manager.makeTicket(ticket: ticket){ result in
            switch(result){
            case .success(let record):
                print(record)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
                DispatchQueue.main.async {
                    let alert = UIAlertController.errorController(error: error)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func setToEditMode(){
        
    }
    
    @objc func changeLabel(_notification: Notification){
        currentAssignedUserLabel.text = currentMember?.owner.username ?? "No Assigned User"
    }
    
//    func createDatePicker() {
//        // create toolbar
//        let toolbar = UIToolbar()
//        toolbar.sizeToFit()
//        toolbar.translatesAutoresizingMaskIntoConstraints = false
//
//        // create bar button
//        //let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneDatePressed))
//        //toolbar.setItems([doneButton], animated: true)
//        //assign toolbar
//        dueDateTextField.inputAccessoryView = toolbar
//
//        // assign date picker to text field
//        dueDateTextField.inputView = datePicker
//
//        // date picker date only mode
//        datePicker.datePickerMode = .date
//
//    }
//
//
//    @objc func doneDatePressed(){
//        // date formatter
//        let formatter = DateFormatter()
//        formatter.dateStyle = .medium
//        formatter.timeStyle = .none
//
//
//        dueDateTextField.text = formatter.string(from: datePicker.date)
//        self.view.endEditing(true)
//    }
//
    
    // MARK: Placeholder text for description
    // Whoever decided to  code UITextView deserves to be beaten
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

//MARK: PopupController manager

class PopupVC: UIViewController {

    @IBOutlet weak var assignedUsersPicker: UIPickerView!
    @IBOutlet weak var pickerViewController: UIPickerView!
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        currentMember = nil  // This was done because pickerView is weird, thus this needs to be forced.
        
        pickerViewController.dataSource = self
        pickerViewController.delegate = self
    }
    
    // Buttons in popup, submit button passes notification to trigger change in assignedUserLabel
    @IBAction func dismissPopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func submitButton(_ sender: Any) {
        NotificationCenter.default.post(name: .changeAssignedUser, object:self)
        dismiss(animated: true, completion: nil)
    }
}


//MARK: UIPickerView manager

extension PopupVC: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return teamMembers.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //print(teamMembers[row])
        //currentMember = teamMembers[row]
        return teamMembers[row]?.owner.username ?? "No Assigned User"
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        currentMember = teamMembers[row]
    }
}

extension Notification.Name {
    static let changeAssignedUser = Notification.Name(rawValue: "changeAssignedUserNotification")
}

