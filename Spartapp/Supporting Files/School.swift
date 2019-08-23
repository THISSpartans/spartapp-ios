//
//  School.swift
//  Spartapp
//
//  Created by 童开文 on 2018/8/16.
//  Copyright © 2018年 童开文. All rights reserved.
//

import Foundation
import UIKit


enum SchoolName:String{
    case TsinghuaInternationalSchool = "Tsinghua International School"
    case InternationalSchoolofBeijing = "International School of Beijing"
}

enum Identity:String{
    case student = "Student"
    case teacher = "Teacher"
}

class School: NSObject, NSCoding{
    
    
    var name: SchoolName = .TsinghuaInternationalSchool
    
    var holidays: [Holiday]? = nil
    
    var calendar: [[Bool]]? = nil
    
    // summer dates
    static var summerStartDate:[SchoolName:(Int,Int)] = [.TsinghuaInternationalSchool:(6,20),.InternationalSchoolofBeijing:(6,21)]
    static var summerEndDate:[SchoolName:(Int,Int)] = [.TsinghuaInternationalSchool:(8,26),.InternationalSchoolofBeijing:(8,12)]
    
    // scheduling
    static var numberOfPeriodPerDay:[SchoolName:Int] = [.TsinghuaInternationalSchool:4,.InternationalSchoolofBeijing:4]
    // class hours of the entire week
    // for example: [[(9,35),(11:15)...] (Monday), [(9,35)...]]
    
    static var scheduleHours:[SchoolName:[[(Int,Int)]]] = [.TsinghuaInternationalSchool:
        
        [[(9,35),(11,15),(12,5),(13,48),(15,15)],
        [(9,35),(11,15),(12,5),(13,48),(15,15)],
        [(8,55),(9,42),(11,25),(12,10),(13,40)],
        [(9,35),(11,15),(12,5),(13,48),(15,15)],
        [(9,35),(11,15),(12,5),(13,48),(15,15)]], .InternationalSchoolofBeijing:
            
        [[(9,40),(11,15),(13,50),(15,35)],
        [(9,40),(11,15),(13,50),(15,35)],
        [(9,35),(11,5),(12,30),(14,25)],
        [(9,40),(11,15),(13,50),(15,35)],
        [(9,40),(11,15),(13,50),(15,35)]]]
    
    static var numberOfSchoolWeeks: [SchoolName:Int] = [.TsinghuaInternationalSchool:43,.InternationalSchoolofBeijing:44]
    
    static var color: [SchoolName:UIColor] = [.TsinghuaInternationalSchool:UIColor(red: 157.0/255.0, green: 67.0/255.0, blue: 180.0/255.0, alpha: 1.0),.InternationalSchoolofBeijing:UIColor(red: 157.0/255.0, green: 67.0/255.0, blue: 180.0/255.0, alpha: 1.0)]
    
    static var powerURL: [SchoolName:String] = [.TsinghuaInternationalSchool:"http://power.this.edu.cn",.InternationalSchoolofBeijing:"http://sis.isb.bj.edu.cn"]
    
    static var usernameID: [SchoolName:String] = [.TsinghuaInternationalSchool:"fieldAccount",.InternationalSchoolofBeijing:"fieldAccount"]
    static var passwordID: [SchoolName:String] = [.TsinghuaInternationalSchool:"fieldPassword",.InternationalSchoolofBeijing:"fieldPassword"]
    static var buttonID: [SchoolName:String] = [.TsinghuaInternationalSchool:"btn-enter-sign-in",.InternationalSchoolofBeijing:"btn-enter-sign-in"]
    static var powerPageTitle: [SchoolName:String] = [.TsinghuaInternationalSchool:"Grades and Attendance",.InternationalSchoolofBeijing:"PowerSchool"]
    
    static var courseCatalog: [String:[String]] = [
        "art": ["ceramics", "easternart6", "easternart7", "easternart8", "easternarti", "easternartii", "foundationsofart", "foundationsofdigitalart", "introtosculpture", "paintingi", "paintingii", "paintingiii", "theartportfolio", "westernart6", "westernart7", "westernart8"],
        "beginningguitar": ["beginningguitar"],
        "biology": ["biology"],
        "chinese": ["apchinese", "chinese6a", "chinese6b", "chinese7a", "chinese7b", "chinese8a", "chinese8b", "chinese9a", "chinese9b", "chinese10a", "chinese10b", "chinese11a", "chinese11b", "chinese12a", "chinese12b"],
        "choir": ["choir"],
        "computer": ["apcomputersciencea", "desktoppublishing", "digitalphotography", "digitalvideo", "grade6computerfoundations", "grade7computerfoundations", "grade8computerfoundations", "introtocomputerscience", "mobileappdesign", "robotici", "roboticii", "webdesign"],
        "filmstudies": ["filmstudyi", "filmstudyii"],
        "french": ["frenchlangi", "frenchlangii", "frenchlangiii", "frenchlangiv"],
        "highschoolenrichment": ["highschoolenrichment"],
        "linguistics": ["linguistics"],
        "music": ["advband8", "band", "beginninginstrumentalmusic", "instrumentalmusicband6", "instrumentalmusicband7", "vocalmusic6", "vocalmusic7"],
        "spanish": ["spanishi", "spanishii", "spanishiii", "spanishiv", "bilingualtranslation"],
        "steam": ["steam", "steami", "steamii", "steamiii", "steamday"],
        "calculus": ["apcalculusab", "apcalculusbc", "calculus", "precalculus", "apstatistics"],
        "math":["advalgebraii", "advgeometry", "algebrai", "algebraii", "algebraiii", "algebraii/trignometry","appliedmath", "geometry", "introtolinearalgebra", "math6", "math7"],
        "chemistry": ["apchemistry", "chemistry"],
        "economics": ["apmacroeconomics", "economics"],
        "english": ["langarts6", "langarts7", "langarts8", "english9", "english10", "english11", "english12", "apenglishlanguage&composition", "apenglishliteraturecomposition","langsupport6", "langsupport7", "langsupport8", "langsupport9", "langsupport10"],
        "history": ["ancientworldhistory7", "apushistory", "apworldhistory", "arthistorymethods", "chinesehistory6", "chinesehistory7", "chinesehistory8", "chinesehistoryi", "chinesehistoryii", "medievalworldhistory8", "modernworldhistory", "ushistory"],
        "socialstudy": ["currentaffairs", "digitalethnography", "foundationsofmodernchina", "humanities", "philosophy","geography6"],
        "physics": ["apphysicsi", "apphysicsii", "lifescience7", "physicalscience8"],
        "earthscience":["earthandspacescience", "earthscience6"],
        "piano": ["pianoi", "pianoii"],
        "studyhall": ["studyhall"],
        "theater": ["advacting", "classicalacting", "theater6", "theater7", "theater8"],
        "genderstudies ": ["genderstudiesi"],
        "health": ["health7", "health8", "health9", "health10"],
        "fitness ": ["advfitness"],
        "sport": ["outdooreducation", "pe6", "pe7", "pe8", "pe9", "sportsmanagement", "strengthtraining", "ultimatesports"],
        "-":["-"]
    ]
    
    static var categoryColor: [String: UIColor] = [
        "art": UIColor(red: 136.0/255.0, green: 100.0/255.0, blue: 136.0/255.0, alpha: 1.0),
        "beginningguitar": UIColor(red: 243.0/255.0, green: 147.0/255.0, blue: 49.0/255.0, alpha: 1.0),
        "biology": UIColor(red: 92.0/255.0, green: 152.0/255.0, blue: 45.0/255.0, alpha: 1.0),
        "chinese": UIColor(red: 64.0/255.0, green: 175.0/255.0, blue: 237.0/255.0, alpha: 1.0),
        "choir": UIColor(red: 206.0/255.0, green: 107.0/255.0, blue: 99.0/255.0, alpha: 1.0),
        "computer": UIColor(red: 73.0/255.0, green: 69.0/255.0, blue: 52.0/255.0, alpha: 1.0),
        "filmstudies": UIColor(red: 164.0/255.0, green: 76.0/255.0, blue: 39.0/255.0, alpha: 1.0),
        "french": UIColor(red: 93.0/255.0, green: 139.0/255.0, blue: 155.0/255.0, alpha: 1.0),
        "highschoolenrichment": UIColor(red: 119.0/255.0, green: 147.0/255.0, blue: 61.0/255.0, alpha: 1.0),
        "linguistics": UIColor(red: 130.0/255.0, green: 82.0/255.0, blue: 40.0/255.0, alpha: 1.0),
        "math": UIColor(red: 119.0/255.0, green: 147.0/255.0, blue: 133.0/255.0, alpha: 1.0),
        "music": UIColor(red: 239.0/255.0, green: 212.0/255.0, blue: 179.0/255.0, alpha: 1.0),
        "spanish": UIColor(red: 198.0/255.0, green: 128.0/255.0, blue: 91.0/255.0, alpha: 1.0),
        "steam": UIColor(red: 209.0/255.0, green: 186.0/255.0, blue: 157.0/255.0, alpha: 1.0),
        "calculus": UIColor(red: 52.0/255.0, green: 54.0/255.0, blue: 51.0/255.0, alpha: 1.0),
        "chemistry": UIColor(red: 208.0/255.0, green: 148.0/255.0, blue: 66.0/255.0, alpha: 1.0),
        "economics": UIColor(red: 229.0/255.0, green: 123.0/255.0, blue: 84.0/255.0, alpha: 1.0),
        "english": UIColor(red: 87.0/255.0, green: 82.0/255.0, blue: 92.0/255.0, alpha: 1.0),
        "history": UIColor(red: 227.0/255.0, green: 157.0/255.0, blue: 88.0/255.0, alpha: 1.0),
        "socialstudy": UIColor(red: 227.0/255.0, green: 220.0/255.0, blue: 206.0/255.0, alpha: 1.0),
        "physics": UIColor(red: 171.0/255.0, green: 166.0/255.0, blue: 136.0/255.0, alpha: 1.0),
        "piano": UIColor(red: 106.0/255.0, green: 91.0/255.0, blue: 81.0/255.0, alpha: 1.0),
        "studyhall": UIColor(red: 12.0/255.0, green: 94.0/255.0, blue: 177.0/255.0, alpha: 1.0),
        "theater": UIColor(red: 160.0/255.0, green: 184.0/255.0, blue: 187.0/255.0, alpha: 1.0),
        "genderstudies": UIColor(red: 147.0/255.0, green: 160.0/255.0, blue: 195.0/255.0, alpha: 1.0),
        "els": UIColor(red: 246.0/255.0, green: 191.0/255.0, blue: 198.0/255.0, alpha: 1.0),
        "health": UIColor(red: 141.0/255.0, green: 190.0/255.0, blue: 223.0/255.0, alpha: 1.0),
        "fitness": UIColor(red: 110.0/255.0, green: 175.0/255.0, blue: 177.0/255.0, alpha: 1.0),
        "sport": UIColor(red: 247.0/255.0, green: 184.0/255.0, blue: 81.0/255.0, alpha: 1.0),
        "-": UIColor.black
    ]
    
    init(holidays:[Holiday]?,calendar:[[Bool]]?,name:String) {
        self.holidays = holidays
        self.calendar = calendar
        self.name = SchoolName(rawValue: name)!
    }
    
    
    private func isWeekend(month:Int,day:Int,year:Int)->Bool{
        
        var dateComponents = DateComponents()
        
        dateComponents.month = month
        dateComponents.day = day
        dateComponents.year = year
        
        let calendar = NSCalendar.current
        return calendar.isDateInWeekend(calendar.date(from: dateComponents)!)
    }
    
    func isSummer(month: Int, day: Int)->Bool{
        
        let currentDate = (month*100)+day
        let ssd = School.summerStartDate[name]!
        let sed = School.summerEndDate[name]!
        return currentDate >= ((ssd.0*100)+ssd.1) && currentDate <= ((sed.0*100)+sed.1)
        
    }
    
    func isSchoolDay(month:Int,day:Int,year:Int)->Bool{
        
        var isHoliday = false
        
        if holidays != nil{
            for holiday in holidays!{
                if holiday.month == month && holiday.day == day{
                    isHoliday = true
                    return holiday.hasSchool
                }
            }
        }
        
        print("isHoliday: \(isHoliday)")
        print(isWeekend(month: month, day: day, year: year))
        
        if !isHoliday{
            return !isWeekend(month:month,day:day,year:year)
        }
    }
    
    // save data to UserDefaults
    
    required convenience init(coder aDecoder: NSCoder) {
        let name = aDecoder.decodeObject(forKey: "School_name") as? String ?? ""
        let holidays = aDecoder.decodeObject(forKey: "School_holidays") as? [Holiday] ?? nil
        let calendar = aDecoder.decodeObject(forKey: "School_calendar") as? [[Bool]] ?? nil
        self.init(holidays: holidays, calendar: calendar,name:name)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(holidays, forKey: "School_holidays")
        aCoder.encode(calendar, forKey: "School_calendar")
        aCoder.encode(name.rawValue,forKey:"School_name")
    }
    
}

class User: NSObject, NSCoding{
    
    var school: School
    
    var identity: Identity = .student{
        didSet{
            if school.name == .TsinghuaInternationalSchool && identity == .teacher{
                School.powerURL[.TsinghuaInternationalSchool] = "http://power.this.edu.cn/teachers"
                School.usernameID[.TsinghuaInternationalSchool] = "fieldUsername"
                School.passwordID[.TsinghuaInternationalSchool] = "fieldPassword"
                School.buttonID[.TsinghuaInternationalSchool] = "btnEnter"
                School.powerPageTitle[.TsinghuaInternationalSchool] = "PowerTeacher"
            }
        }
    }
    
    var schedule: [[Course]]?
    
    var clubs:[Club]?
    
    var grades:[Club]?
    
    init(school: School, identity: Identity,schedule:[[Course]]?,clubs:[Club]?,grades:[Club]?) {
        self.school = school
        self.identity = identity
        self.schedule = schedule
        self.clubs = clubs
        self.grades = grades
    }
    
    // save data to UserDefaults
    
    required convenience init(coder aDecoder: NSCoder) {
        let school = aDecoder.decodeObject(forKey: "User_school") as! School
        let identity = aDecoder.decodeObject(forKey: "User_identity") as! String
        let schedule = aDecoder.decodeObject(forKey: "User_schedule") as? [[Course]] ?? nil
        let clubs = aDecoder.decodeObject(forKey: "User_clubs") as? [Club] ?? nil
        let grades = aDecoder.decodeObject(forKey: "User_grades") as? [Club] ?? nil
        self.init(school: school, identity: Identity(rawValue: identity)!, schedule:schedule, clubs: clubs, grades: grades)
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(school, forKey: "User_school")
        aCoder.encode(identity.rawValue, forKey: "User_identity")
        aCoder.encode(schedule,forKey: "User_schedule")
        aCoder.encode(clubs,forKey:"User_clubs")
        aCoder.encode(grades,forKey:"User_grades")
    }
    
}
