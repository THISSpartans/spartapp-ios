//
//  NewsTableViewCell.swift
//  Spartapp
//
//  Created by 童开文 on 2018/11/29.
//  Copyright © 2018 童开文. All rights reserved.
//

import UIKit
import SafariServices

class NewsTableViewCell: UITableViewCell {

    @IBOutlet weak var newsBackgroundView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var newsLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var newsImage: UIImageView!
    
    //if url is blank (""), hide the button
    
    @IBOutlet weak var readMoreButton: WebButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
