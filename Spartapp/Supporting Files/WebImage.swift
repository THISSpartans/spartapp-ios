//
//  WebImage.swift
//  Spartapp
//
//  Created by Andrew Li on 15 August 19.
//  Copyright © 2019 Kevin Tong. All rights reserved.
//

import Foundation
import UIKit

class WebImage: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private var loaded: Bool = false
    
    func isLoad() {
        loaded = true
    }
    
    func getLoad() -> Bool {
        return self.loaded
    }
    
}
