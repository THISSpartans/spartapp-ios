//
//  TomorrowClassIntentHandler.swift
//  SpartappIntent
//
//  Created by 童开文 on 2018/11/7.
//  Copyright © 2018 童开文. All rights reserved.
//
import UIKit
import Foundation


class TomorrowClassIntentHandler: NSObject, TomorrowClassIntentHandling {
    
    var day = 0
    
    func confirm(intent: TomorrowClassIntent, completion: @escaping (TomorrowClassIntentResponse) -> Void) {
        
        day = returnDay()
        if day == -1{
            completion(TomorrowClassIntentResponse(code: .noClass, userActivity: nil))
        }else{
            print(day)
            completion(TomorrowClassIntentResponse(code: .success, userActivity: nil))
        }
        
    }
    func handle(intent: TomorrowClassIntent, completion: @escaping (TomorrowClassIntentResponse) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.kevintong.SpartappSiri")
        
        let schedule = sharedDefaults?.array(forKey: "schedule") as! [[String]]
        
        day = returnDay()
        
        if day != -1{
            let todayClasses = schedule[day-1]
            var response = ""
            for cla in todayClasses{
                response += cla
                response += " "
            }
            completion(TomorrowClassIntentResponse.success(classes: response))
        }
    }
    
    func returnDay()->Int{
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
        
        let now = currentDate()
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
    
    
    func currentDate()->(Int,Int){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let now = dateFormatter.string(from: Calendar.current.date(byAdding: .day, value: 1, to: Date())!)
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


