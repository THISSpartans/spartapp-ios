//
//  TodayViewController.swift
//  Spartapp Widget
//
//  Created by 童开文 on 2018/4/1.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit
import NotificationCenter

import Foundation


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

extension Date {
    var yesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var tomorrow: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return tomorrow.month != month
    }
}


class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var classTableView: UITableView!
    
    var user: User!
    
    var monthNames:[String] = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    var today = 0
    
    var classes = [String]()
    
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var classNameLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var bigTodayLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var todayButton: UIButton!
    @IBOutlet weak var noSchoolLabel: UILabel!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    var smallWidgetIndex = 0
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if activeDisplayMode == .expanded{
            preferredContentSize = CGSize(width: 0.0, height: 427.0)
            
            if today >= 0{
                classTableView.isHidden = false
                noSchoolLabel.isHidden = true
                todayButton.isHidden = false
            }else{
                classTableView.isHidden = true
                noSchoolLabel.isHidden = false
                todayButton.isHidden = true
            }
            
            classNameLabel.isHidden = true
            previousButton.isHidden = true
            nextButton.isHidden = true
            todayLabel.isHidden = true
            periodButton.isHidden = true
            bigTodayLabel.isHidden = false
            dateLabel.isHidden = false
            backgroundImageView.isHidden = false
            
        }else{
            
            preferredContentSize = maxSize
            self.viewDidLoad()
            classTableView.isHidden = true
            classNameLabel.isHidden = false
            todayLabel.isHidden = false
            noSchoolLabel.isHidden = true
            bigTodayLabel.isHidden = true
            dateLabel.isHidden = true
            todayButton.isHidden = true
            backgroundImageView.isHidden = true
            if today >= 0{
                periodButton.isHidden = false
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sharedDefaults = UserDefaults.init(suiteName: "group.com.kevintong.Spartapp")
        let encodedObject = sharedDefaults?.object(forKey: "Shared_User")
        user = NSKeyedUnarchiver.unarchiveObject(with: encodedObject as! Data) as! User
        
        view.sendSubview(toBack: backgroundImageView)
        todayButton.layer.cornerRadius = 10.0
        classTableView.delegate = self
        classTableView.dataSource = self
        classTableView.allowsSelection = false
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        
        classNameLabel.adjustsFontSizeToFitWidth = true
        
        let date = currentDate(nextDay: false)
        let time = currentTime()
        
        today = returnToDay(month: date.0, day: date.1)
        
        var year: Int{
            if date.0 >= 8 {
                return 2019
            }else{
                return 2020
            }
        }
        if today == -1 {
            
            if time.0 >= 16{
                // display tomorrow
                displayNextDay()
                
                let nDate = currentDate(nextDay: true)
                let nToday = returnToDay(month: nDate.0, day: nDate.1)
                if nToday != -1{
                    today = nToday
                    smallViewSetUp()
                    schoolDayDisplay()
                }else{
                    noSchoolDisplay()
                }
            }else{
                displayToday()
                noSchoolDisplay()
            }
            
        }else{
            
            let calendar = NSCalendar.current
            let weekday = calendar.component(.weekday, from: NSDate() as Date)
            
            // wednesday is 4, friday is 6...
            let scheduleHR = School.scheduleHours[user.school.name]![weekday-2]
            
            // [(9,35),(11,15),(12,5),(13,50),(15,15)]
            
            
            if time.0 > scheduleHR.last!.0 || (time.0 == scheduleHR.last!.0 && time.1 >= scheduleHR.last!.1){
                // tomorrow
                displayNextDay()
                let nDate = currentDate(nextDay: true)
                let nToday = returnToDay(month: nDate.0, day: nDate.1)
                if nToday != -1{
                    today = nToday
                    smallViewSetUp()
                    schoolDayDisplay()
                }else{
                    noSchoolDisplay()
                }
            }else{
                displayToday()
                smallViewSetUp()
                schoolDayDisplay()
            }
            
        }
       
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return classes.count
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
        
        if bigTodayLabel.text == "Today"{
            cell.backgroundColor = UIColor(red: 34.0/255.0, green: 142.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }else{
            cell.backgroundColor = UIColor(red: 34.0/255.0, green: 101.0/255.0, blue: 180.0/255.0, alpha: 1.0)
        }
        
        cell.classNameLabel.adjustsFontSizeToFitWidth = true
        cell.classNameLabel.textColor = .white
        cell.layer.cornerRadius = 10.0
        
        cell.classNameLabel.text = classes[indexPath.section]
        if cell.classNameLabel.text == ""{
            cell.classNameLabel.text = "-"
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        completionHandler(NCUpdateResult.newData)
    }
    
    
    @IBAction func previousClass(_ sender: Any) {
        if smallWidgetIndex > 0{
            smallWidgetIndex = smallWidgetIndex - 1
            periodButton.setTitle(String(smallWidgetIndex+1), for: .normal)
            classNameLabel.text = classes[smallWidgetIndex]
            if classNameLabel.text == ""{
                classNameLabel.text = "-"
            }
        }
        if smallWidgetIndex == 0{
            previousButton.isEnabled = false
        }
        nextButton.isEnabled = true
    }
    
    
    @IBAction func nextClass(_ sender: Any) {
        if smallWidgetIndex < (classes.count - 1){
            smallWidgetIndex = smallWidgetIndex + 1
            periodButton.setTitle(String(smallWidgetIndex+1), for: .normal)
            classNameLabel.text = classes[smallWidgetIndex]
            if classNameLabel.text == ""{
                classNameLabel.text = "-"
            }
        }
        if smallWidgetIndex == (classes.count - 1){
            nextButton.isEnabled = false
        }
        
        if smallWidgetIndex > 0{
            previousButton.isEnabled = true
        }
        
    }
    
    
    func nDaysInMonth(month: Int)->Int{
        switch month{
        case 9, 11, 4:
            return 30
        case 6:
            return (School.summerStartDate[user.school.name]?.1)!
        case 2:
            return 28
        default:
            return 31
        }
    }
    
    //MARK: - Return Day
    
    func returnToDay(month: Int, day: Int)->Int{
        
        var year: Int{
            if month>=8{
                return 2019
            }else{
                return 2020
            }
        }
        if user.school.isSchoolDay(month: month, day: day, year: year) == false || user.school.isSummer(month: month, day: day){
            return -1
        }
        
        var dayDifference = 0
        
        if (month == 8){
            dayDifference = day - (School.summerEndDate[user.school.name]?.1)!
        }else if (month > 8){
            for i in 9..<month{
                dayDifference += self.nDaysInMonth(month: i)
            }
            dayDifference += nDaysInMonth(month: 8) - (School.summerEndDate[user.school.name]?.1)!
            dayDifference += day
        }else{
            for i in 9...12{
                dayDifference += self.nDaysInMonth(month: i)
            }
            for i in 1..<month{
                dayDifference += self.nDaysInMonth(month: i)
            }
            dayDifference += nDaysInMonth(month: 8) - (School.summerEndDate[user.school.name]?.1)!
            dayDifference += day
        }
        
        var falseCounter = 0
        
        for i in 0..<(dayDifference/7){
            for day in user.school.calendar![i]{
                if day == false{
                    falseCounter += 1
                }
            }
        }
        for i in 0..<(dayDifference%7){
            if user.school.calendar![dayDifference/7][i] == false{
                falseCounter += 1
            }
        }
        
        let schoolDays = dayDifference-falseCounter
        
        if user.school.name == .TsinghuaInternationalSchool{
            
            today = schoolDays % 6
            
            if today == 0{
                today = 6
            }
        }else{
            // return two digit: 12 -> day A second rotational way
            if (schoolDays/8)%2 == 0{
                // day A
                return 10+(schoolDays%8)
            }else{
                // day B
                return 20+(schoolDays%8)
            }
        }
        
        return today
    }
    
    // MARK: - ISB Return starting class index
    
    func isbStartIndexOf(category: Int)->Int{
        switch category {
        case 0:
            return 5
        case 1:
            return 0
        case 2:
            return 4
        case 3:
            return 3
        case 4:
            return 7
        case 5:
            return 2
        case 6:
            return 6
        case 7:
            return 1
        default:
            return -1
        }
    }
    
    func currentDate(nextDay:Bool)->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        var date = dateFormatter.string(from: NSDate() as Date)
        
        if nextDay == true{
            date = dateFormatter.string(from: Date().tomorrow)
        }
        return (Int(date[0...1])!,Int(date[3...4])!)
    }
    
    func currentTime()->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let now = dateFormatter.string(from: NSDate() as Date)
        return (Int(now[11...12])!,Int(now[14...15])!)
    }
    
    func displayNextDay(){
        todayLabel.text = "Tomorrow"
        bigTodayLabel.text = "Tomorrow"
        backgroundImageView.image = UIImage(named: "widgetBGNight")
        todayButton.backgroundColor = .white
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let date = dateFormatter.string(from: Date().tomorrow)
        dateLabel.text = "\(monthNames[Int(date[0...1])!-1]) \(date[3...4])"
    }
    
    func displayToday(){
        todayLabel.text = "Today"
        bigTodayLabel.text = "Today"
        backgroundImageView.image = UIImage(named: "widgetBG")
        dateLabel.text = "\(monthNames[currentDate(nextDay: false).0-1]) \(currentDate(nextDay: false).1)"
    }
    
    func schoolDayDisplay(){
        noSchoolLabel.isHidden = false
        classNameLabel.isHidden = false
        nextButton.isHidden = false
        previousButton.isHidden = false
        todayButton.isHidden = false
        classTableView.isHidden = false
    }
    
    func noSchoolDisplay(){
        classNameLabel.isHidden = true
        nextButton.isHidden = true
        previousButton.isHidden = true
        todayButton.isHidden = true
        noSchoolLabel.text = "No School Today"
        classTableView.isHidden = true
    }
    
    func populateClasses(){
        // append classes into the "classes" array for display later
        if user.school.name == .TsinghuaInternationalSchool{
            classes.removeAll()
            for className in user.schedule![today-1]{
                classes.append(className.name)
            }
        }else{
            // ISB
            
            let courses = user.schedule!
            classes.removeAll()
            var schedule = [[String]]()
            
            for row in courses{
                var classNames = [String]()
                for column in row{
                    classNames.append(column.name)
                }
                schedule.append(classNames)
            }
            
            
            let day = (today/10) - 1
            let classe = schedule[day]
            let startIndex = isbStartIndexOf(category: today%10)
            
            for i in 0..<4{
                var index = startIndex + i
                if (today%10)%2 != 0{
                    if index >= 4{
                        index = index - 4
                    }
                }else{
                    if index >= 8{
                        index = index - 4
                    }
                }
                
                classes.append(classe[index])
            }
        }
    }
    
    func smallViewSetUp(){
        // set up small view
        classNameLabel.text = classes[smallWidgetIndex]
        if classNameLabel.text == ""{
            classNameLabel.text = "-"
        }
        if smallWidgetIndex == 0{
            previousButton.isEnabled = false
        }
        periodButton.layer.cornerRadius = 5.0
        periodButton.backgroundColor = UIColor(red: 255.0/255.0, green: 186.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        periodButton.setTitle(String(smallWidgetIndex + 1), for: .normal)
        periodButton.setTitleColor(.black, for: .normal)
        var todayText = String(today)
        if user.school.name == .InternationalSchoolofBeijing{
            switch today/10{
            case 1:
                todayText = "A"
            case 2:
                todayText = "B"
            default:
                break
            }
        }
        todayButton.setTitle(todayText, for: .normal)
        todayButton.setTitleColor(.black, for: .normal)
    }
    
}
