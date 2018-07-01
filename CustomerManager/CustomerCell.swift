//
//  MyCustomCellTableViewCell.swift
//  CustomerManager
//
//  Created by Wu hung-yi on 19/03/2018.
//  Copyright © 2018 Wu. All rights reserved.
//

import UIKit

class CustomerCell: UITableViewCell {

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
