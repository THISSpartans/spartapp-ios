//
//  ScheduleViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/20.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit
import LeanCloud
import Intents

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



class ScheduleViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource{
    
    var user: User!
    
    let defaults = UserDefaults.standard
    
    let sharedDefaults = UserDefaults(suiteName: "group.com.kevintong.SpartappSiri")
    
    var scheduleTable: [[Course]] = [[Course]]()
    
    @IBOutlet weak var noSchoolLabel: UILabel!
    
    var today = 4
    
    
    @IBOutlet weak var expandButton: UIButton!
    
    var currentClassIndex = 0
    
    var month = 0
    
    var placeholder = 0
    
    var monthNames:[String] = ["January","February","March","April","May","June","July","August","September","October","November","December"]
    
    var selectedDate: Int!
    
    var hasSelectedDate = false
    
    let weekdays = ["S","M","T","W","T","F","S"]
    
    var classColors:[UIColor] = [UIColor(red: 227.0/255.0, green: 220.0/255.0, blue: 206.0/255.0, alpha: 1.0),UIColor(red: 247.0/255.0, green: 184.0/255.0, blue: 81.0/255.0, alpha: 1.0),UIColor(red: 92.0/255.0, green: 152.0/255.0, blue: 45.0/255.0, alpha: 1.0),UIColor(red: 171.0/255.0, green: 166.0/255.0, blue: 136.0/255.0, alpha: 1.0)]
    
    @IBOutlet weak var dayCollectionViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var refreshCalendarButton: UIBarButtonItem!
    @IBOutlet weak var scheduleTableView: UITableView!
    @IBOutlet weak var dayCollectionView: UICollectionView!
    @IBOutlet weak var nextMonthButton: UIBarButtonItem!
    @IBOutlet weak var previousMonthButton: UIBarButtonItem!
    @IBOutlet weak var weekdayCollectionView: UICollectionView!
    
    var fromWalkthrough: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("booyay")
        
        // rotate expand button
        expandButton.isHidden = true
        
        weekdayCollectionView.allowsSelection = false
        
        // donate today's classes intent
        
        if #available(iOS 12.0, *) {
            let intent = ClassesOfTheDayIntent()
            intent.suggestedInvocationPhrase = "Today's classes"
            
            let interaction = INInteraction(intent: intent, response: nil)
            
            interaction.donate { (error) in
                if error != nil {
                    if let error = error as NSError? {
                        print(error)
                    } else {
                        print("Successfully donated interaction")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        
        // donate tomorrow's class intent
        
        if #available(iOS 12.0, *) {
            let intent2 = TomorrowClassIntent()
            intent2.suggestedInvocationPhrase = "Tomorrow's classes"
            let interaction2 = INInteraction(intent: intent2, response: nil)
            
            interaction2.donate { (error) in
                if error != nil {
                    if let error = error as NSError? {
                        print(error)
                    } else {
                        print("Successfully donated interaction")
                    }
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
        
        
        // get user
        // if user has an instance saved, retrieve it
        // else, present walk through
        
        if let decodedUser = defaults.object(forKey: "User") as? Data{
            user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as! User
            user.identity = user.identity
            if user.school.name == .InternationalSchoolofBeijing{
                if (tabBarController?.viewControllers?.count)! > 2{
                    tabBarController?.viewControllers?.removeLast()
                }
            }
        }else{
            if let pageViewController =
                storyboard?.instantiateViewController(withIdentifier: "PageViewController") as?
                PageWTViewController {
                self.present(pageViewController, animated: true, completion: nil)
                fromWalkthrough = true
            }
        }
        
        // get schedule
        // if user has schedule saved, retrieve it and display
        // else, present empty page
        
        if user != nil && user.schedule != nil{
            
            
            // save data for Siri
            
            // schedule
            
            var courseNames = [[String]]()
            
            for day in self.user.schedule!{
                var dayNames = [String]()
                for course in day{
                    dayNames.append(course.name)
                }
                courseNames.append(dayNames)
            }
            sharedDefaults?.set(courseNames, forKey: "schedule")
            
            // calendar
            
            sharedDefaults?.set(self.user.school.calendar!, forKey: "calendar")
            
            // holiday
            
            // 10,1,0
            // 4,22,0
            // first two digit is the month, second two is the day, 0 is no school 1 is school
            
            var holidays = [[Int]]()
            for holiday in self.user.school.holidays!{
                var ho = [Int]()
                ho.append(holiday.month)
                ho.append(holiday.day)
                if holiday.hasSchool == true{
                    ho.append(1)
                }else{
                    ho.append(0)
                }
                holidays.append(ho)
            }
            sharedDefaults?.set(holidays, forKey: "holidays")
            
            sharedDefaults?.synchronize()
            
            
            // display setup
            
            noSchoolLabel.isHidden = true
            scheduleTableView.isHidden = false
            previousMonthButton.isEnabled = true
            nextMonthButton.isEnabled = true
            
            // get date
            
            let todate = currentDate()
            month = todate.0
            // get holidays & calendar
            print("month: \(month)")
            
            
            
            setupCollectionView()
            setupNavBar()
            
            var year: Int {
                if month >= 8{
                    return 2018
                }else{
                    return 2019
                }
            }
            
            
            
            placeholder = getDayOfWeek("\(year)-\(month)-01")! - 1
            
            selectedDate = (todate.1-1)
            let indexPath = NSIndexPath(item: selectedDate, section: 0)
            collectionView(dayCollectionView, didSelectItemAt: indexPath as IndexPath)
            dayCollectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: .centeredHorizontally)
            
            
        }else{
            self.scheduleTableView.isHidden = true
            previousMonthButton.isEnabled = false
            nextMonthButton.isEnabled = false
            noSchoolLabel.text = "you have not set up your courses yet"
            
        }
        
        // background color
        view.backgroundColor = .white
            
    }
    
    
    //MARK: - TableView
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if user.school.name == .TsinghuaInternationalSchool{
            if today != -1{
                return user.schedule![today-1].count
            }else{
                return 0
            }
        }else{
           return 4
        }
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if today != -1{
            if user.school.name == .TsinghuaInternationalSchool{
                
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
                
                print("today \(today)")
                print(indexPath.section)
                cell.titleLabel.text = user.schedule![today-1][indexPath.section].name
                
                if cell.titleLabel.text == ""{
                    cell.titleLabel.text = "- "
                }
                var courseTitle = cell.titleLabel.text!.replacingOccurrences(of: " ", with: "").lowercased()
                if courseTitle != "-"{
                    courseTitle.removeLast()
                }
                print(courseTitle)
                let imageTitle = categoryOf(courseName: courseTitle)
                cell.backgroundImages.image = UIImage(named: imageTitle)
                cell.teacherNameLabel.text = user.schedule![today-1][indexPath.section].teacher
                cell.roomNumberLabel.text = user.schedule![today-1][indexPath.section].room
                
                cell.backgroundImages.layer.cornerRadius = cell.backgroundImages.frame.width/2
                cell.backgroundImages.clipsToBounds = true
                
                cell.periodLabel.text = "P\(indexPath.section + 1)"
                
                cell.backgroundColor = .clear
                
                if indexPath.section == currentClassIndex{
                    // purple border & etc
                }
                
                cell.titleLabel.adjustsFontSizeToFitWidth = true
                cell.teacherNameLabel.adjustsFontSizeToFitWidth = true
                cell.roomNumberLabel.adjustsFontSizeToFitWidth = true
                
                
                return cell
                
                
            }else{
                
                
                if indexPath.section == currentClassIndex{
                    
                    var classIndex = currentClassIndex + isbStartIndexOf(category: today%10)
                    
                    if (today%10)%2 != 0{
                        if classIndex > 4{
                            classIndex = classIndex - 4
                        }
                    }else{
                        if classIndex > 8{
                            classIndex = classIndex - 4
                        }
                    }
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
                    
                    cell.titleLabel.text = user.schedule![(today/10)-1][classIndex].name
                    
                    var courseTitle = cell.titleLabel.text!.replacingOccurrences(of: " ", with: "").lowercased()
                    courseTitle.removeLast()
                    let imageTitle = categoryOf(courseName: courseTitle)
                    cell.backgroundImages.image = UIImage(named: imageTitle)
                    
                    cell.teacherNameLabel.text = user.schedule![(today/10)-1][classIndex].teacher
                    cell.roomNumberLabel.text = user.schedule![(today/10)-1][classIndex].room
                    
                    
                    cell.titleLabel.adjustsFontSizeToFitWidth = true
                    cell.teacherNameLabel.adjustsFontSizeToFitWidth = true
                    cell.roomNumberLabel.adjustsFontSizeToFitWidth = true
                    
                    return cell
                    
                }else{
                    let startClassIndex = isbStartIndexOf(category: today%10)
                    
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ClassTableViewCell
                    
                    var clas = Course()
                    
                    if (today%10)%2 != 0{
                        if startClassIndex + indexPath.section >= 4{
                            
                            clas = user.schedule![(today/10)-1][startClassIndex + indexPath.section - 4]
                            
                        }else{
                            clas = user.schedule![(today/10)-1][startClassIndex + indexPath.section]
                        }
                    }else{
                        if startClassIndex + indexPath.section >= 8{
                            clas = user.schedule![(today/10)-1][startClassIndex + indexPath.section - 4]
                        }else{
                            clas = user.schedule![(today/10)-1][startClassIndex + indexPath.section]
                        }
                    }
                    
                    cell.titleLabel.text = clas.name
                    
                    var courseTitle = cell.titleLabel.text!.replacingOccurrences(of: " ", with: "").lowercased()
                    courseTitle.removeLast()
                    let imageTitle = categoryOf(courseName: courseTitle)
                    cell.backgroundImages.image = UIImage(named: imageTitle)
                    
                    cell.teacherNameLabel.text = clas.teacher
                    cell.roomNumberLabel.text = clas.room
                    
                    cell.titleLabel.adjustsFontSizeToFitWidth = true
                    cell.teacherNameLabel.adjustsFontSizeToFitWidth = true
                    cell.roomNumberLabel.adjustsFontSizeToFitWidth = true
                    
                    return cell
                }
            }
        }
        
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return (88/667)*screenHeight
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return (20/667)*screenHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return 30.0
        }else{
            return 0.0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    
        
    // MARK: - CollectionView
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == weekdayCollectionView{
            return 7
        }else{
            
            var year: Int {
                if month >= 8{
                    return 2018
                }else{
                    return 2019
                }
            }
            
            let dateComponents = DateComponents(year: year, month: month)
            let calendar = Calendar.current
            let date = calendar.date(from: dateComponents)!
            
            let placeholders = getDayOfWeek("\(year)-\(month)-01")! - 1
            
            
            let range = calendar.range(of: .day, in: .month, for: date)!
            
            if dayCollectionViewHeight.constant > 100{
                return range.count + placeholders
            }else{
                return range.count
            }
        }
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        
        if collectionView == weekdayCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "weekdayCell", for: indexPath) as! WeekdayCollectionViewCell
            cell.dayLabel.text = weekdays[indexPath.row]
            return cell
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DateCollectionViewCell
            cell.backgroundColor = .clear
            cell.dateLabel.backgroundColor = .white
            
            if dayCollectionViewHeight.constant > 100 {
                cell.weekdayLabel.isHidden = true
                
                if (indexPath.row + 1) <= placeholder{
                    cell.dateLabel.text = ""
                }else{
                    cell.dateLabel.text = "\((indexPath.row + 1) - placeholder)"
                }
                
                if month == currentDate().0 && indexPath.item - placeholder == currentDate().1 - 1{
                    cell.dateLabel.backgroundColor = UIColor(red: 212.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                    cell.dateLabel.layer.cornerRadius = cell.frame.width/2
                    cell.dateLabel.clipsToBounds = true
                }
                
            }else{
                
                
                cell.dateLabel.text = "\(indexPath.row + 1)"
                cell.weekdayLabel.isHidden = false
                print(cell.dateLabel.text)
                
                var year: Int {
                    if month >= 8{
                        return 2018
                    }else{
                        return 2019
                    }
                }
                
                cell.weekdayLabel.text = weekdays[getDayOfWeek("\(year)-\(month)-\(cell.dateLabel.text!)")!-1]
                
                if month == currentDate().0 && indexPath.item == currentDate().1 - 1{
                    cell.dateLabel.backgroundColor = UIColor(red: 212.0/255.0, green: 204.0/255.0, blue: 204.0/255.0, alpha: 1.0)
                    cell.dateLabel.layer.cornerRadius = cell.frame.width/2
                    cell.dateLabel.clipsToBounds = true
                }
            }
            
            if dayCollectionViewHeight.constant > 100{
                if cell.dateLabel.text != "" && (Int(cell.dateLabel.text!)!+placeholder-1) == selectedDate {
                    cell.dateLabel.backgroundColor = School.color[user.school.name]
                    cell.dateLabel.layer.cornerRadius = cell.frame.width/2
                    cell.dateLabel.clipsToBounds = true
                }else{
                    cell.backgroundColor = .white
                }
            }else{
                if (Int(cell.dateLabel.text!)!-1) == selectedDate {
                    cell.dateLabel.backgroundColor = School.color[user.school.name]
                    cell.dateLabel.layer.cornerRadius = cell.frame.width/2
                    cell.dateLabel.clipsToBounds = true
                }else{
                    cell.backgroundColor = .white
                }
            }
            
            
            return cell
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if indexPath.row >= placeholder || collectionView.frame.height < 100{
            if hasSelectedDate == false{
                let cell = collectionView.cellForItem(at: indexPath)
            }else{
                let cell = collectionView.cellForItem(at: indexPath) as! DateCollectionViewCell
                cell.dateLabel.backgroundColor = School.color[user.school.name]
                cell.dateLabel.layer.cornerRadius = cell.frame.width/2
                cell.dateLabel.clipsToBounds = true
            }
            
            hasSelectedDate = true
            
            collectionView.deselectItem(at: NSIndexPath(item: selectedDate, section: 0) as IndexPath, animated: true)
            
            selectedDate = indexPath.row
            
            print("weeeeeeeee \(selectedDate)")
            
            if dayCollectionViewHeight.constant > 100{
                self.today = self.returnToDay(month: month, day: (selectedDate+1)-placeholder)
                print("weeeeeeeeeeeeeeeee \(self.today)")
            }else{
                self.today = self.returnToDay(month: month, day: (selectedDate+1))
                print("weeho \(self.today)")
                print("weehoo \(selectedDate+1)")
            }
            
            
            print("today: \(today)")
            if self.today == -1{
                holidayMode()
                print("hell yeah")
            }else{
                print("lalala")
                setupTableView()
                self.noSchoolLabel.isHidden = true
                scheduleTableView.isHidden = false
                scheduleTableView.reloadData()
            }
            
            dayCollectionView.reloadData()
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if hasSelectedDate == false{
            let cell = collectionView.cellForItem(at: indexPath) as! DateCollectionViewCell
            cell.dateLabel.backgroundColor = .white
        }
        
    }
    
    
    //MARK: - ChangeMonth
    
    @IBAction func nextMonth(_ sender: Any) {
        if self.month == 12{
            self.month = 1
        }else if self.month == 5{
            self.month += 1
            self.nextMonthButton.isEnabled = false
        }else{
            self.month = self.month + 1
        }
        
        var year: Int{
            if month >= 8{
                return 2018
            }else{
                return 2019
            }
        }
        
        if dayCollectionView.frame.height > 100{
            selectedDate -= placeholder
        }
        
        placeholder = getDayOfWeek("\(year)-\(month)-01")! - 1
        
        if dayCollectionView.frame.height > 100{
            selectedDate += placeholder
        }
        
        previousMonthButton.isEnabled = true
        
        navigationController?.navigationBar.topItem?.title = monthNames[self.month-1]
        self.dayCollectionView.reloadData()
        
        if selectedDate > dayCollectionView.numberOfItems(inSection: 0) - 1{
            selectedDate = dayCollectionView.numberOfItems(inSection: 0) - 1
        }
        hasSelectedDate = false
        let indexPath = NSIndexPath(item: selectedDate, section: 0)
        collectionView(dayCollectionView, didSelectItemAt: indexPath as IndexPath)
        dayCollectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        
        self.scheduleTableView.reloadData()
        self.noSchoolLabel.isHidden = true
        
        
    }
    
    @IBAction func previousMonth(_ sender: Any) {
        
        if self.month == 9{
            self.month = self.month - 1
            self.previousMonthButton.isEnabled = false
        }else if self.month == 1{
            self.month = 12
        }else{
            self.month -= 1
        }
        
        var year: Int{
            if month >= 8{
                return 2018
            }else{
                return 2019
            }
        }
        
        if dayCollectionView.frame.height > 100{
            selectedDate -= placeholder
        }
        
        placeholder = getDayOfWeek("\(year)-\(month)-01")! - 1
        
        if dayCollectionView.frame.height > 100{
            selectedDate += placeholder
        }
        
        nextMonthButton.isEnabled = true
        
        navigationController?.navigationBar.topItem?.title = monthNames[self.month-1]
        self.dayCollectionView.reloadData()
        
        if selectedDate > dayCollectionView.numberOfItems(inSection: 0) - 1{
            selectedDate = dayCollectionView.numberOfItems(inSection: 0) - 1
        }
        hasSelectedDate = false
        let indexPath = NSIndexPath(item: selectedDate, section: 0)
        collectionView(dayCollectionView, didSelectItemAt: indexPath as IndexPath)
        dayCollectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: .centeredHorizontally)
        
        
        self.scheduleTableView.reloadData()
        self.noSchoolLabel.isHidden = true
        
    }
    
    @IBAction func refreshCalendar(_ sender: Any) {
        
        var holidayName = ""
        var calendarName = ""
        if user.school.name == .TsinghuaInternationalSchool{
            holidayName = "Holidays"
            calendarName = "Calendar"
        }else{
            holidayName = "Holidays_ISB"
            calendarName = "Calendar_ISB"
        }
        
        if user != nil{
            
            fetchHolidays(withClass: holidayName) { (true) in
                self.fetchCalendar(withClass: calendarName, completion: { (true) in
                    if let decodedUser = self.defaults.object(forKey: "User") as? Data{
                        self.user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as! User
                        self.user.identity = self.user.identity
                        print("Done")
                    }
                })
            }
        }
    }
    
    @IBAction func expand(_ sender: Any) {
        // shrink
        if dayCollectionViewHeight.constant > 100{
            
            expandButton.setImage(UIImage(named: "expandButton"), for: .normal)
            dayCollectionViewHeight.constant = 70
            dayCollectionView.isScrollEnabled = true
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (38/375)*UIScreen.main.bounds.width, height: (68/667)*UIScreen.main.bounds.height)
            layout.sectionInset = UIEdgeInsets(top: 0, left: (13/375)*UIScreen.main.bounds.width, bottom: 0, right: (13/375)*UIScreen.main.bounds.width)
            layout.minimumLineSpacing = (14/375)*UIScreen.main.bounds.width
            layout.scrollDirection = .horizontal
            
            dayCollectionView.collectionViewLayout = layout
            dayCollectionView.allowsMultipleSelection = false
            
            // scroll & select
            
            dayCollectionView.reloadData()
            
            hasSelectedDate = false
            selectedDate -= placeholder
            
            let indexPath = NSIndexPath(item: selectedDate, section: 0)
            dayCollectionView.scrollToItem(at: NSIndexPath(item: 20, section: 0) as IndexPath, at: .centeredHorizontally, animated: true)
            collectionView(dayCollectionView, didSelectItemAt: indexPath as IndexPath)
            
            
            weekdayCollectionView.isHidden = true
        }else{
            // expand
            weekdayCollectionView.isHidden = false
            expandButton.setImage(UIImage(named: "shrinkButton"), for: .normal)
            dayCollectionView.isScrollEnabled = true
            dayCollectionViewHeight.constant = 323
            
            let layout = UICollectionViewFlowLayout()
            layout.itemSize = CGSize(width: (38/375)*UIScreen.main.bounds.width, height: (68/667)*UIScreen.main.bounds.height)
            layout.sectionInset = UIEdgeInsets(top: 0, left: (13/375)*UIScreen.main.bounds.width, bottom: 0, right: (13/375)*UIScreen.main.bounds.width)
            layout.minimumLineSpacing = (0/375)*UIScreen.main.bounds.width
            layout.scrollDirection = .vertical
            dayCollectionView.contentSize.height = ((68/667)*UIScreen.main.bounds.height)*4
            dayCollectionView.collectionViewLayout = layout
            dayCollectionView.allowsMultipleSelection = false
            
            
            // scroll & select
            
            var year: Int {
                if month >= 8{
                    return 2018
                }else{
                    return 2019
                }
            }
            placeholder = getDayOfWeek("\(year)-\(month)-01")! - 1
            
            
            dayCollectionView.reloadData()
            hasSelectedDate = false
            print("weee \(selectedDate)")
            selectedDate += placeholder
            print("weeeee \(selectedDate)")
            let indexPath = NSIndexPath(item: selectedDate, section: 0)
            collectionView(dayCollectionView, didSelectItemAt: indexPath as IndexPath)
            dayCollectionView.scrollToItem(at: indexPath as IndexPath, at: .centeredHorizontally, animated: true)
            
            weekdayCollectionView.isHidden = false
        }
        
        
    }
    
    
    //MARK: - Return Day
    
    func returnToDay(month: Int, day: Int)->Int{
        let now = currentDate()
        
        var year: Int{
            if month>=8{
                return 2018
            }else{
                return 2019
            }
        }
        
        if user.school.isSchoolDay(month: month, day: day, year: year) == false || user.school.isSummer(month: month, day: day){
            print("woew")
            return -1
        }
        
        if month != now.0 || day != now.1{
            self.currentClassIndex = 0
        }else{
            self.currentClassIndex = self.returnCurrentClassIndex()
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
            
//            if today == 1{
//                today = 6
//            }else{
//                today -= 1
//            }
            
            
            
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
    
    
    // MARK: - ReturnCurrentClassIndex
    func returnCurrentClassIndex()->Int{
        
        var periodIndex = 0
        
        let calendar = NSCalendar.current
        let weekday = calendar.component(.weekday, from: NSDate() as Date)

        // wednesday is 4, friday is 6...
        let scheduleHR = School.scheduleHours[user.school.name]![weekday-2]
        let time = currentTime()
        
        // [(9,35),(11,15),(12,5),(13,50),(15,15)]
        for block in scheduleHR{
            if time.0 > block.0{
                periodIndex += 1
            }else if time.0 == block.0 && time.1 > block.1{
                periodIndex += 1
            }
        }
        
        print("Period Index \(periodIndex)")
        
        if user.school.name == .TsinghuaInternationalSchool{
            // highschool or middleschool
            
            var nClasses = 0
            
            for scheduledDay in user.schedule!{
                nClasses+=scheduledDay.count
            }
            
            if nClasses/6 == 4{ // high school
                if periodIndex == 3 || periodIndex == 4{
                    periodIndex -= 1
                }else if periodIndex > 4{
                    periodIndex = 0
                }
            }else{ // middle school
                if periodIndex > 4{
                    periodIndex = 0
                }
            }
            
            return periodIndex
            
        }else{
            if periodIndex > 3{
                return 0
            }else{
                return periodIndex
            }
        }
    }
    
    // MARK: - Days in a Month
    
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
    
    // MARK: - return category name
    
    func categoryOf(courseName: String)->String{
        for category in School.courseCatalog{
            for course in category.value{
                if course == courseName{
                    return category.key
                }
            }
        }
        return ""
    }
    
    // MARK: - Fetch Calendar
    func fetchCalendar(withClass className: String, completion: @escaping (Bool)->Void){
        
        let query = LCQuery(className: className)
        query.whereKey("weekNumber", .lessThan(50))
        query.find { result in
            switch result {
            case .success(let objects):
                self.user.school.calendar?.removeAll()
                for i in 0..<objects.count{
                    let week = objects[i].get("weeklyCalendar")?.arrayValue as! [Bool]
                    let nWeek = objects[i].get("weekNumber")?.intValue
                    self.user.school.calendar = [[Bool]](repeatElement([Bool](), count: objects.count))
                    self.user.school.calendar![nWeek!-1] = week
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: - fetch holidays
    
    
    func fetchHolidays(withClass className: String, completion: @escaping (Bool)->Void){
        
        let queryHoliday = LCQuery(className: className)
        queryHoliday.whereKey("included", .equalTo(true))
        queryHoliday.find { result in
            switch result {
            case .success(let objects):
                self.user.school.holidays?.removeAll()
                for object in objects{
                    
                    let date = object.get("date")?.stringValue!
                    
                    // 0 is noSchool 1 is school
                    var isSchool = false
                    if object.get("isSchool")?.intValue! == 1{
                        isSchool = true
                    }
                    
                    let holi = Holiday(name: (object.get("holidayName")?.stringValue)!, day: Int(date![3...4])!, month: Int(date![0...1])!, hasSchool: isSchool)
                    self.user.school.holidays = [Holiday]()
                    self.user.school.holidays?.append(holi)
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
 
    
    func currentDate()->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let now = dateFormatter.string(from: NSDate() as Date)
        return (Int(now[0...1])!,Int(now[3...4])!)
    }
    
    func currentTime()->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let now = dateFormatter.string(from: NSDate() as Date)
        return (Int(now[11...12])!,Int(now[14...15])!)
    }
    
    func setupCollectionView(){
        
        expandButton.setImage(UIImage(named: "shrinkButton"), for: .normal)
        expandButton.isHidden = false
        
        dayCollectionView.isHidden = false
        dayCollectionView.delegate = self
        dayCollectionView.dataSource = self
        
        weekdayCollectionView.delegate = self
        weekdayCollectionView.dataSource = self
        
        expandButton.setImage(UIImage(named: "expandButton"), for: .normal)
        dayCollectionView.isScrollEnabled = true
        
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (38/375)*UIScreen.main.bounds.width, height: (68/667)*UIScreen.main.bounds.height)
        layout.sectionInset = UIEdgeInsets(top: 0, left: (13/375)*UIScreen.main.bounds.width, bottom: 0, right: (13/375)*UIScreen.main.bounds.width)
        layout.minimumLineSpacing = (14/375)*UIScreen.main.bounds.width
        
        
        layout.scrollDirection = .horizontal
        
        dayCollectionView.collectionViewLayout = layout
        dayCollectionView.allowsMultipleSelection = false
        
        let layout2 = UICollectionViewFlowLayout()
        layout2.itemSize = CGSize(width: (38/375)*UIScreen.main.bounds.width, height: (80/667)*UIScreen.main.bounds.height)
        layout2.sectionInset = UIEdgeInsets(top: 0, left: (13/375)*UIScreen.main.bounds.width, bottom: 0, right: (13/375)*UIScreen.main.bounds.width)
        layout2.minimumLineSpacing = (13/375)*UIScreen.main.bounds.width
        weekdayCollectionView.collectionViewLayout = layout2
        
        weekdayCollectionView.isHidden = true
    }
    
    func setupTableView(){
        
        // set up table view
        scheduleTableView.delegate = self
        scheduleTableView.dataSource = self
        scheduleTableView.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
    }
    
    func setupNavBar(){
        
        var month = currentDate().0
        
        if month == 6{
            nextMonthButton.isEnabled = false
        }else if month == 8{
            previousMonthButton.isEnabled = false
        }else if month == 7{
            navigationController?.navigationBar.topItem?.title = monthNames[month-2]
            month = 6
            nextMonthButton.isEnabled = false
        }
        
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.topItem?.title = monthNames[month-1]
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "SFUIDisplay-Bold", size: 22) ?? UIFont()]
    }
    
    func holidayMode(){
        scheduleTableView.isHidden = true
        self.noSchoolLabel.isHidden = false
        self.noSchoolLabel.text = "No School Today"
    }
    
    public func saveObject(_ object: Any, forKey key: String){
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
        userDefaults.set(encodedData, forKey: key)
        userDefaults.synchronize()
    }
    
    // MARK: - Segues
    @IBAction func unwindToSchedule(segue:UIStoryboardSegue){
        self.viewDidLoad()
    }
 
    @IBAction func unwindToScheduleWOData(segue:UIStoryboardSegue){
        if fromWalkthrough == true{
            if user == nil{
                if let decodedUser = defaults.object(forKey: "User") as? Data{
                    user = NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as! User
                    user.identity = user.identity
                    if user.school.name == .InternationalSchoolofBeijing{
                        tabBarController?.viewControllers?.removeLast()
                    }
                }
            }
            fromWalkthrough = false
        }
    }
    
   
    func openUpdateSchedule(shortcutIdentifier: ShortcutIdentifier) -> Bool {
        switch shortcutIdentifier {
        case .updateSchedule:
            performSegue(withIdentifier: "updateSchedule", sender: nil)
        default:
            return false
        }
        return true
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
 
}
