//
//  WebButton.swift
//  Spartapp
//
//  Created by Andrew Li on 14 August 19.
//  Copyright © 2019 Andrew Li. All rights reserved.
//

/**
 * This file is basically the read more text on each news cell
 * I use this instead of UIButton so I could add a url embed in the button itself rather than somewhere else -> each news cell has a custom link...or none
 **/

import Foundation
import UIKit

class WebButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var url: String = ""
    
    func setUrl(url: String) {
        self.url = url
    }
    
    func getUrl() -> String {
        return self.url
    }
    
}
