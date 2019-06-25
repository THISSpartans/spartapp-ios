//
//  IntentViewController.swift
//  SpartappIntentUI
//
//  Created by 童开文 on 2018/11/6.
//  Copyright © 2018 童开文. All rights reserved.
//

import IntentsUI

// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

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
    static var summerStartDate:[SchoolName:(Int,Int)] = [.TsinghuaInternationalSchool:(6,21),.InternationalSchoolofBeijing:(6,21)]
    static var summerEndDate:[SchoolName:(Int,Int)] = [.TsinghuaInternationalSchool:(8,27),.InternationalSchoolofBeijing:(8,12)]
    
    // scheduling
    static var numberOfPeriodPerDay:[SchoolName:Int] = [.TsinghuaInternationalSchool:4,.InternationalSchoolofBeijing:4]
    // class hours of the entire week
    // for example: [[(9,35),(11:15)...] (Monday), [(9,35)...]]
    
    static var scheduleHours:[SchoolName:[[(Int,Int)]]] = [.TsinghuaInternationalSchool:
        
        [[(9,35),(11,15),(12,5),(13,50),(15,15)],
         [(9,35),(11,15),(12,5),(13,50),(15,15)],
         [(8,55),(9,40),(11,25),(12,10),(13,40)],
         [(9,35),(11,15),(12,5),(13,50),(15,15)],
         [(9,35),(11,15),(12,5),(13,50),(15,15)]], .InternationalSchoolofBeijing:
            
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
    static var buttonID: [SchoolName:String] = [.TsinghuaInternationalSchool:"btn-enter",.InternationalSchoolofBeijing:"btn-enter-sign-in"]
    static var powerPageTitle: [SchoolName:String] = [.TsinghuaInternationalSchool:"Grades and Attendance",.InternationalSchoolofBeijing:"PowerSchool"]
    
    static var courseCatalog: [String:[String]] = [
        "art": ["ceramics", "easternart6", "easternart7", "easternart8", "easternarti", "easternartii", "foundationsofart", "foundationsofdigitalart", "introtosculpture", "paintingi", "paintingii", "paintingiii", "theartportfolio", "westernart6", "westernart7", "westernart8"],
        "beginningguitar": ["beginningguitar"],
        "biology": ["biology"],
        "chinese": ["apchinese", "chinese6a", "chinese6b", "chinese7a", "chinese7b", "chinese8a", "chinese8b", "chinese9a", "chinese9b", "chinese10a", "chinese10b", "chinese11a", "chinese11b", "chinese12a", "chinese12b"],
        "choir": ["choir"],
        "computer": ["apcomputersciencea", "desktoppublishing", "digitalphotography", "digitalvideo", "grade6computerfoundations", "grade7computerfoundations", "grade8computerfoundations", "introtocomputerscience", "mobileappdesign", "roboticsi", "roboticsii", "webdesign"],
        "filmstudies": ["filmstudyi", "filmstudyii"],
        "french": ["frenchlangi", "frenchlangii", "frenchlangiii", "frenchlangiv"],
        "highschoolenrichment": ["highschoolenrichment"],
        "linguistics": ["linguistics"],
        "music": ["advband8", "band", "beginninginstrumentalmusic", "instrumentalmusicband6", "instrumentalmusicband7", "vocalmusic6", "vocalmusic7"],
        "spanish": ["spanishi", "spanishii", "spanishiii", "spanishiv", "bilingualtranslation"],
        "steam": ["steam", "steami", "steamii", "steamiii", "steamday"],
        "calculus": ["apcalculusab", "apcalculusbc", "calculus", "precalculus","advalgebraii", "advgeometry", "algebrai", "algebraii", "algebraiii", "algebraii/trignometry", "apstatistics", "appliedmath", "geometry", "introtolinearalgebra", "math6", "math7"],
        "chemistry": ["apchemistry", "chemistry"],
        "economics": ["apmacroeconomics", "economics"],
        "english": ["langarts6", "langarts7", "langarts8", "english9", "english10", "english11", "english12", "apenglishlanguage&composition", "apenglishliteraturecomposition","langsupport6", "langsupport7", "langsupport8", "langsupport9", "langsupport10"],
        "history": ["ancientworldhistory7", "apushistory", "apworldhistory", "arthistorymethods", "chinesehistory6", "chinesehistory7", "chinesehistory8", "chinesehistoryi", "chinesehistoryii", "medievalworldhistory8", "modernworldhistory", "ushistory"],
        "socialstudy": ["currentaffairs", "digitalethnography", "foundationsofmodernchina", "humanities", "philosophy"],
        "physics": ["apphysicsi", "apphysicsii", "earthandspacescience", "earthscience6", "geography6", "lifescience7", "physicalscience8"],
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


extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}



class IntentViewController: UIViewController, INUIHostedViewControlling, UITableViewDelegate,UITableViewDataSource {
    
    
    @IBOutlet weak var weekdayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var classesTableView: UITableView!
    
    var weekdayNames = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
    var monthNames = ["January"," February","March","April","May","June","July","August","September","October","November","December"]
    
    var classes = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        classesTableView.delegate = self
        classesTableView.dataSource = self
        
    }
    
    // MARK: - INUIHostedViewControlling
    
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        // Do configuration here, including preparing views and calculating a desired size for presentation.
        
        let width = self.extensionContext?.hostedViewMaximumAllowedSize.width ?? 320
        let desiredSize = CGSize(width: width, height: 300)
        
        var isTomorrow = true
        
        if interaction.intent is ClassesOfTheDayIntent{
            isTomorrow = false
        }
        
        let calendar = NSCalendar.current
        var weekday = 0
        if isTomorrow == true{
            weekday = calendar.component(.weekday, from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        }else{
            weekday = calendar.component(.weekday, from: NSDate() as Date)
        }
        
        // wednesday is 4, friday is 6...
        weekdayLabel.text = weekdayNames[weekday-2]
        
        let now = currentDate(isTomorrow: isTomorrow)
        dateLabel.text = "\(monthNames[now.0-1]) \(now.1)"
        
        
        let sharedDefaults = UserDefaults(suiteName: "group.com.kevintong.SpartappSiri")
        let schedule = sharedDefaults?.array(forKey: "schedule") as! [[String]]
        let day = returnDay(isTomorrow: isTomorrow)
        classes = schedule[day-1]
        
        classesTableView.reloadData()
        
        completion(true, parameters, desiredSize)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return classes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SiriClassTableViewCell
        
        cell.periodLabel.text = "period \(indexPath.row + 1)"
        cell.classNameLabel.text = classes[indexPath.row]
        
        return cell
    }
    
    func returnDay(isTomorrow: Bool)->Int{
        let sharedDefaults = UserDefaults(suiteName: "group.com.kevintong.SpartappSiri")
        let calendar = sharedDefaults?.array(forKey: "calendar") as! [[Bool]]
        
        var holidays = [Holiday]()
        
        let decodedHolidays = sharedDefaults?.array(forKey: "holidays") as! [[Int]]
        
        // 10,1,0
        // 4,22,0
        // first two digit is the month, second two is the day, 0 is no school 1 is school
        
        for decHoli in decodedHolidays{
            
            var hasSchool = false
            
            if decHoli[2] == 1{
                hasSchool = true
            }
            
            let holi = Holiday(name: "", day: decHoli[1], month: decHoli[0], hasSchool: hasSchool)
            holidays.append(holi)
        }
        
        
        let now = currentDate(isTomorrow: isTomorrow)
        let month = now.0
        let day = now.1
        
        let school = School(holidays: holidays, calendar: calendar, name: "Tsinghua International School")
        
        var year: Int{
            if month>=8{
                return 2018
            }else{
                return 2019
            }
        }
        
        
        if school.isSchoolDay(month: month, day: day, year: year) == false || school.isSummer(month: month, day: day){
            // no class
            return -1
        }else{
            // has class
            
            var dayDifference = 0
            
            if (month == 8){
                dayDifference = day - (School.summerEndDate[.TsinghuaInternationalSchool]?.1)!
            }else if (month > 8){
                for i in 9..<month{
                    dayDifference += self.nDaysInMonth(month: i)
                }
                dayDifference += nDaysInMonth(month: 8) - (School.summerEndDate[.TsinghuaInternationalSchool]?.1)!
                dayDifference += day
            }else{
                for i in 9...12{
                    dayDifference += self.nDaysInMonth(month: i)
                }
                for i in 1..<month{
                    dayDifference += self.nDaysInMonth(month: i)
                }
                dayDifference += nDaysInMonth(month: 8) - (School.summerEndDate[.TsinghuaInternationalSchool]?.1)!
                dayDifference += day
            }
            
            var falseCounter = 0
            
            for i in 0..<(dayDifference/7){
                for day in calendar[i]{
                    if day == false{
                        falseCounter += 1
                    }
                }
            }
            for i in 0..<(dayDifference%7){
                if calendar[dayDifference/7][i] == false{
                    falseCounter += 1
                }
            }
            
            let schoolDays = dayDifference-falseCounter
            
            var today = schoolDays % 6
            
            if today == 0{
                today = 6
            }
            
            return today
        }
    }
    
    func currentDate(isTomorrow: Bool)->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var now = ""
        if isTomorrow == true{
            now = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
        }else{
            now = dateFormatter.string(from: NSDate() as Date)
        }
        return (Int(now[0...1])!,Int(now[3...4])!)
    }
    
    func nDaysInMonth(month: Int)->Int{
        switch month{
        case 9, 11, 4:
            return 30
        case 6:
            return (School.summerStartDate[.TsinghuaInternationalSchool]?.1)!
        case 2:
            return 28
        default:
            return 31
        }
    }
    
}
