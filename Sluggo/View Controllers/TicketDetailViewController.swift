//
//  TicketDetailViewController.swift
//  Sluggo
//
//  Created by Stephan Martin on 4/30/21.
//

import UIKit

class TicketDetailViewController: UIViewController, UITextViewDelegate {
    
    public var identity: AppIdentity
    public var ticket: TicketRecord?
    let stackView = UIStackView()
    var ticketDescription = UITextView()
    
    init? (coder: NSCoder, identity: AppIdentity) {
        self.identity = identity
        super.init(coder: coder)
    }
    
    required init? (coder: NSCoder) {
        fatalError("must be initialized with identity")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let LightGrayColor = UIColor(displayP3Red: 12, green: 12, blue: 12, alpha: 1)
        
        view.backgroundColor = .white
        let ticketTitle = UITextField()
        // title.translatesAutoresizingMaskIntoConstraints = false
        ticketTitle.borderStyle = .roundedRect
        ticketTitle.contentHorizontalAlignment = .center
        ticketTitle.contentVerticalAlignment = .top
        ticketTitle.textAlignment = .center
        ticketTitle.font = UIFont.systemFont(ofSize: 30, weight: .bold)
        ticketTitle.borderStyle = .bezel
        ticketTitle.backgroundColor = LightGrayColor
        ticketTitle.adjustsFontSizeToFitWidth = true
        ticketTitle.placeholder = "Title of Ticket"
        
        ticketDescription.delegate = self
        ticketDescription.textAlignment = .center
        ticketDescription.font = UIFont.systemFont(ofSize: 20)
        
        // This is placeholder text, make sure to account for it when accepting submissions
        ticketDescription.textColor = .lightGray
        ticketDescription.text = "Description of Ticket"
        // Real text should be in black textColor, not lightGray. Use that to determine submissions
        
        
        
        //view.addSubview(testLabel)
        
        stackView.addArrangedSubview(ticketTitle)
        stackView.addArrangedSubview(ticketDescription)
        
        stackView.backgroundColor = .white
        view.addSubview(stackView)
        stackView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        stackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        
        //stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        // stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //stackView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        //stackView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.45).isActive = true



        
        
        
    }
    // MARK: Placeholder text for description
    // Whoever decided to not code placeholder text for UITextView deserves to be beaten
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


