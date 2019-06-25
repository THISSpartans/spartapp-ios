//
//  SiriClassTableViewCell.swift
//  SpartappIntentUI
//
//  Created by 童开文 on 2018/11/7.
//  Copyright © 2018 童开文. All rights reserved.
//

import UIKit

class SiriClassTableViewCell: UITableViewCell {

    @IBOutlet weak var periodLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
