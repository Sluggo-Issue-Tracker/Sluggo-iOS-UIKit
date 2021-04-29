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
            containerView.layer.shadowColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
            containerView.layer.shadowRadius = 5
        }
    }
    
    @IBOutlet var ticketStatus: UIView! {
        didSet {
            ticketStatus.layer.cornerRadius = 5
        }
    }
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var assignedLabel: UILabel!
}
