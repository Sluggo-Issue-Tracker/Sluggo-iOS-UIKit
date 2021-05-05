//
//  TeamTableViewCell.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/4/21.
//

import UIKit

class TeamTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        self.accessoryType = (selected) ? .checkmark : .none
    }

}
