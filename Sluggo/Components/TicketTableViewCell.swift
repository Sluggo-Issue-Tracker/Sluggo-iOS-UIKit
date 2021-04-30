//
//  TicketTableViewCell.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 4/28/21.
//

import UIKit

class TicketTableViewCell: UITableViewCell {
    @IBOutlet var containerView: UIView! {
        didSet {
            containerView.layer.cornerRadius = 5
        }
    }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var assignedLabel: UILabel!
    
    func loadFromTicketRecord(ticket: TicketRecord) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "en_US")
        
        titleLabel.text = "\(ticket.ticket_number) | \(ticket.title.capitalized)"
        if let date = ticket.due_date {
            assignedLabel.text = formatter.string(from: date)
        } else {
            assignedLabel.text = ""
        }
        
        if let color = ticket.status?.color {
            containerView.backgroundColor = UIColor(hex: color.lowercased())
        } else {
            containerView.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        }
    }
}
