//
//  NewsTableViewCellDesign.swift
//  Spartapp
//
//  Created by 童开文 on 2018/11/29.
//  Copyright © 2018 童开文. All rights reserved.
//

import Foundation
import UIKit

extension CALayer {
    func applySketchShadow(
        color: UIColor = UIColor(red: 191/255.0, green: 187.0/255.0, blue: 187.0/255.0, alpha: 1.0),
        alpha: Float = 0.5,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blur: CGFloat = 7,
        spread: CGFloat = 0)
    {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / 2.0
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
}

class NewsTableViewCellDesign: UIView{
    override func layoutSubviews() {
        layer.cornerRadius = 5.0
        layer.applySketchShadow()
    }
}

