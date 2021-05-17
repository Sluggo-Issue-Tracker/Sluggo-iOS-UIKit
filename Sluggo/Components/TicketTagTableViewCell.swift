//
//  TicketTagTableViewCell.swift
//  Sluggo
//
//  Created by Stephan Martin on 5/16/21.
//

import UIKit

class TicketTagTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization Code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        super.accessoryType = selected ? .checkmark : .none
        // configures the view for the selected state
    }
}
