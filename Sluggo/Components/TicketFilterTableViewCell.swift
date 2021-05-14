//
//  TicketFilterTableViewCell.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/12/21.
//

import UIKit

class TicketFilterTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        super.accessoryType = selected ? .checkmark : .none
        // Configure the view for the selected state
    }

}
