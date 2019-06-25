//
//  Course.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/27.
//  Copyright © 2018年 童开文. All rights reserved.
//

import Foundation

class ClassDay: NSObject, NSCoding{
    
    var days: [String]
    var period: String
    var part: Int
    
    override init(){
        days = []
        period = ""
        part = 0
        super.init()
    }
    init(days: [String], period: String, part: Int) {
        self.days = days
        self.period = period
        self.part = part
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(days, forKey: "ClassDay_days")
        aCoder.encode(period, forKey: "Course_period")
        aCoder.encode(part, forKey: "Course_part")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.days = aDecoder.decodeObject(forKey: "ClassDay_days") as? [String] ?? []
        self.period = aDecoder.decodeObject(forKey: "Course_period") as? String ?? ""
        self.part = aDecoder.decodeObject(forKey: "Course_part") as? Int ?? 0
        
        super.init()
    }
   
}

class Course: NSObject, NSCoding {
    
    var name: String
    var teacher: String
    var room: String
    var day: ClassDay
    
    override init(){
        name = ""
        teacher = ""
        room = ""
        day = ClassDay(days: [], period: "", part: 0)
        super.init()
    }
    
    init(name: String, teacher: String, room: String, day: ClassDay) {
        self.name = name
        self.teacher = teacher
        self.room = room
        self.day = day
    }
    
    required init?(coder aDecoder: NSCoder){
        self.name = aDecoder.decodeObject(forKey: "Course_name") as! String
        self.teacher = aDecoder.decodeObject(forKey: "Course_teacher") as! String
        self.room = aDecoder.decodeObject(forKey: "Course_room") as! String
        self.day = aDecoder.decodeObject(forKey: "Course_day") as! ClassDay
        
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "Course_name")
        aCoder.encode(teacher, forKey: "Course_teacher")
        aCoder.encode(room, forKey: "Course_room")
        aCoder.encode(day, forKey: "Course_day")
    }
    
}

class Club: NSObject, NSCoding{
    var clubName: String
    var isSelected: Bool
    
    override init(){
        clubName = ""
        isSelected = false
        super.init()
    }
    
    init(clubName: String, isSelected: Bool) {
        self.clubName = clubName
        self.isSelected = isSelected
    }
    
    required init?(coder aDecoder: NSCoder){
        self.clubName = aDecoder.decodeObject(forKey: "Club_clubName") as! String
        self.isSelected = aDecoder.decodeBool(forKey: "Club_isSelected")
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.clubName, forKey: "Club_clubName")
        aCoder.encode(isSelected, forKey: "Club_isSelected")
    }
    
    
}
