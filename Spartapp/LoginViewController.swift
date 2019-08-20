//
//  LoginViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/27.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit
import WebKit
import SwiftSoup
import LeanCloud
import Foundation

class LoginViewController: UIViewController,WKNavigationDelegate{
    
    var user: User!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var studentSchedule: [[Course]] = [[Course]]()
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var failureLabel: UILabel!
    
    var counter = 0
    let webView = WKWebView()
    
    var timer: Timer!
    var loadTimer: Timer!
    
    var loadLimit = 0
    var loginLimit = 0
    
    var didBeginToLoad = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let decodedUser = UserDefaults.standard.object(forKey: "User") as? Data{
            user = (NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as! User)
        }
        
        user.identity = user.identity
        
        failureLabel.isHidden = true
        passwordTextField.isSecureTextEntry = true

        // set up login button
        loginButton.setTitle("loading", for: .normal)
        loginButton.isEnabled = false
        
        // set placeholder text
        
        usernameTextField.attributedPlaceholder = NSAttributedString(string: "username",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "password",attributes:[NSAttributedString.Key.foregroundColor: UIColor.white])
        
        // set up text fields
        usernameTextField.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(self.editingChanged), for: .editingChanged)
        
        // set up web view
        
        let request = URLRequest(url: URL(string: School.powerURL[user.school.name]!)!)
        webView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        webView.load(request)
        //view.addSubview(webView)
        
        
        self.loadTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.loadLogin), userInfo: nil, repeats: true)
        
        if user.school.name == .TsinghuaInternationalSchool{
            for _ in 0..<6{
                studentSchedule.append([Course](repeating: Course(name: "", teacher: "", room: "", day: ClassDay(days: [], period: "", part: 0)), count: 8))
            }
        }else{
            for _ in 0..<2{
                studentSchedule.append([Course](repeating: Course(name: "", teacher: "", room: "", day: ClassDay(days: [], period: "", part: 0)), count: 8))
            }
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard
            let habit = usernameTextField.text, !habit.isEmpty,
            let goal = passwordTextField.text, !goal.isEmpty
            else {
                self.loginButton.isEnabled = false
                return
        }
        if self.webView.isLoading == false{
            self.loginButton.isEnabled = true
        }
    }
    
    
    @objc func loadLogin(){
        self.loadLimit += 1
        if self.loadLimit < 50 {
            if self.webView.isLoading == false{
                self.loadTimer.invalidate()
                print("loaded")
                self.loginButton.setTitle("Login", for: .normal)
                
                guard
                    let habit = usernameTextField.text, !habit.isEmpty,
                    let goal = passwordTextField.text, !goal.isEmpty
                    else {
                        self.loginButton.isEnabled = false
                        return
                }
                self.loginButton.isEnabled = true
            }
        }else{
            self.performSegue(withIdentifier: "unwindToScheduleWOData", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Login(_ sender: Any) {
        
            failureLabel.isHidden = true
        
            
            webView.evaluateJavaScript("document.getElementById('\(School.usernameID[user.school.name]!)').value='\(usernameTextField.text!)'", completionHandler:nil)
            webView.evaluateJavaScript("document.getElementById('\(School.passwordID[user.school.name]!)').value='\(self.passwordTextField.text!)'", completionHandler:nil)
        
            webView.evaluateJavaScript("document.getElementById('\(School.buttonID[user.school.name]!)').click();", completionHandler: { (result, error) in
                    
                self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.delay), userInfo: nil, repeats: true)
                    
                self.loginButton.isEnabled = false
                self.loginButton.setTitle("fetching schedule", for: .normal)
            })
        
    }
    
    @objc func delay(){
        
        let pageTitle = School.powerPageTitle[user.school.name]
        
        loadSchedule(withPageTitle: pageTitle!) { (true) in
            if user.school.name == .TsinghuaInternationalSchool{
                _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.fetchSchedule), userInfo: nil, repeats: false)
            }else{
                webView.evaluateJavaScript("window.location.href='/guardian/home.html?mobileHome=main'", completionHandler: { (result, error) in
                    self.loginLimit = 0
                    self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.delayISB), userInfo: nil, repeats: true)
                    
                })
            }
        }
        
    }
    
    @objc func delayISB(){
        print("delay ISB")
        loadSchedule(withPageTitle: "Grades and Attendance") { (true) in
            _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.fetchSchedule), userInfo: nil, repeats: false)
        }
    }
    
    
    @objc func fetchSchedule(){
        
        self.webView.evaluateJavaScript("document.getElementsByTagName('html')[0].innerHTML"){ (innerHTML, error) in
            do{
                
                let schedule = try Schedule(innerHTML)
                
                DispatchQueue.main.async {
                    
                    if self.user.school.name == .TsinghuaInternationalSchool{
                        for course in schedule.courses{
                            print(course.day.days[0])
                            self.studentSchedule[Int(course.day.days[0])!-1][(Int(course.day.period)!*2 - abs(course.day.part-1))-1] = course
                        }
                    }else{
                        for cla in schedule.courses{
                            for day in cla.day.days{
                                let period = Int(cla.day.period)!-1
                                if period < 8{
                                    if day == "A"{
                                        self.studentSchedule[0][period] = cla
                                    }else{
                                        self.studentSchedule[1][period] = cla
                                    }
                                }
                                
                            }
                        }
                        
                    }
                    
                    if self.user.school.name == .TsinghuaInternationalSchool{
                        for j in 0..<6{
                            var counter = 0
                            for i in 0..<8{
                                if (i%2 != 0){
                                    if self.studentSchedule[j][(i-counter)].name == self.studentSchedule[j][(i-counter)-1].name{
                                        self.studentSchedule[j].remove(at: (i-counter))
                                        counter += 1
                                    }
                                }
                            }
                        }
                    }
                    
                    // TODO: - save schedule table to user instance
                    self.user.schedule = self.studentSchedule
                    
                    var holidayName = ""
                    var calendarName = ""
                    if self.user.school.name == .TsinghuaInternationalSchool{
                        holidayName = "Holidays"
                        calendarName = "Calendar"
                    }else{
                        holidayName = "Holidays_ISB"
                        calendarName = "Calendar_ISB"
                    }
                    
                    
                    self.fetchHolidays(withClass: holidayName, completion: { (true) in
                        self.fetchCalendar(withClass: calendarName, completion: { (true) in
                            self.saveObject(self.user, forKey: "User")
                            
                            
                            // save data for Siri
                            
                            // schedule
                            let sharedDefaults = UserDefaults.init(suiteName: "group.com.kevintong.SpartappSiri")
                            
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
                            
                            self.performSegue(withIdentifier: "unwindToSchedule", sender: self)
                        })
                    })
                    
                    
                }
            }catch{}
        }
        
        
        
    }
    
    // MARK: - Helper Methods
    public func saveObject(_ object: Any, forKey key: String){
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
        userDefaults.set(encodedData, forKey: key)
        userDefaults.synchronize()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    func loadSchedule(withPageTitle title: String, completion: (Bool)->Void){
        
        if self.webView.isLoading == true{
            didBeginToLoad = true
        }
        
        if self.webView.isLoading == false && self.webView.title != title{
            failureLabel.isHidden = false
            // internet problem
            print("internet problem")
            self.timer.invalidate()
            self.failureLabel.text = "Connection Problems, Try Again"
            self.loginButton.setTitle("Login", for: .normal)
            self.loginButton.isEnabled = true
            self.counter = 0
        }else{
            self.loginLimit += 1
            if loginLimit < 500{
                if self.webView.title == title && self.webView.isLoading == false{
                    print(self.loadLimit)
                    self.timer.invalidate()
                    print("got it!")
                    
                    completion(true)
                    
                }
            }else{
                self.performSegue(withIdentifier: "unwindToScheduleWOData", sender: self)
            }
        }
    }
    
    // MARK: - Fetch Calendar
    func fetchCalendar(withClass className: String, completion: @escaping (Bool) -> Void){
        
        let query = LCQuery(className: className)
        query.whereKey("weekNumber", .lessThan(50))
        query.find { result in
            switch result {
            case .success(let objects):
                
                self.user.school.calendar = [[Bool]](repeatElement([Bool](), count: objects.count))
                
                for i in 0..<objects.count{
                    let week = objects[i].get("weeklyCalendar")?.arrayValue as! [Bool]
                    let nWeek = objects[i].get("weekNumber")?.intValue
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
                
                self.user.school.holidays = [Holiday]()
                
                for object in objects{
                    
                    let date = object.get("date")?.stringValue!
                    
                    // 0 is noSchool 1 is school
                    var isSchool = false
                    if object.get("isSchool")?.intValue! == 1{
                        isSchool = true
                    }
                    
                    let holi = Holiday(name: (object.get("holidayName")?.stringValue)!, day: Int(date![3...4])!, month: Int(date![0...1])!, hasSchool: isSchool)
                    self.user.school.holidays?.append(holi)
                    print(holi.name)
                    
                }
                
                DispatchQueue.main.async {
                    completion(true)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    // MARK: - Navigation
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//
//
//    }
    
    
}
