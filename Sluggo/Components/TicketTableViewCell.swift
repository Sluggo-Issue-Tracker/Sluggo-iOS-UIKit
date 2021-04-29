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
            containerView.layer.shadowRadius = 5
            containerView.layer.shadowOpacity = 1
            containerView.layer.shadowColor = UIColor.systemGray.cgColor
            containerView.layer.shadowOffset = CGSize(width: 3, height: 3)
        }
    }
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var assignedLabel: UILabel!
}
