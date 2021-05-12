//
//  CodablePickerTableViewCell.swift
//  Sluggo
//
//  Created by Samuel Schmidt on 5/12/21.
//

import UIKit

class CodablePickerTableViewCell<T: Codable>: UITableViewCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var pickerData: [T]!
    var getTitle: ((T) -> String)! // this could proabaly get replaced with computer properties
    var onCompletion: ((T) -> Void)!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    // MARK: data source contract
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.getTitle(pickerData[row])
    }
    
}
