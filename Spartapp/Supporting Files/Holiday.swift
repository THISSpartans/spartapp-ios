//
//  Holiday.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/25.
//  Copyright © 2018年 童开文. All rights reserved.
//

import Foundation

class Holiday: NSObject, NSCoding{
    
    var name: String
    var day: Int
    var month: Int
    var hasSchool: Bool
    
    init(name: String, day: Int, month: Int, hasSchool: Bool) {
        self.name = name
        self.day = day
        self.month = month
        self.hasSchool = hasSchool
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Holiday_name")
        aCoder.encode(month, forKey: "Holiday_month")
        aCoder.encode(day, forKey: "Holiday_day")
        aCoder.encode(hasSchool, forKey: "Holiday_hasSchool")
    }
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "Holiday_name") as! String
        let month = aDecoder.decodeInteger(forKey: "Holiday_month")
        let day = aDecoder.decodeInteger(forKey: "Holiday_day")
        let hasSchool = aDecoder.decodeBool(forKey: "Holiday_hasSchool")
        
        self.init(name: name, day: day, month: month, hasSchool: hasSchool)
    }
    
}
