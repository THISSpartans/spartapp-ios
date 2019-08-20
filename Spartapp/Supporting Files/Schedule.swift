//
//  Schedule.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/27.
//  Copyright © 2018年 童开文. All rights reserved.
//

import Foundation
import SwiftSoup

extension String {
    public func substring(from index: Int) -> String {
        if self.count > index {
            let startIndex = self.index(self.startIndex, offsetBy: index+1)
            let subString = self[startIndex..<self.endIndex]

            return String(subString)
        } else {
            return self
        }
    }
}

func indexOf(character: Character, text: String)->[Int]{
    var indexes: [Int] = [Int]()
    var counter = 0
    var sum = 0
    for char in text{
        if char == character{
            if (sum==0){
                indexes.append(counter-sum)
            } else {
                indexes.append(counter-sum-1)
            }
            sum = counter
        }
        counter = counter + 1
    }
    return indexes
}

func intValue(char: Character)->Int{
    switch char{
    case "A":
        return 10
    case "B":
        return 20
    default:
        return Int(String(char))!
    }
}

enum HTMLError: Error{
    case badInnerHTML
}

func indexBeforeWord(word: String, string: String)->Int{
    var index = -1
    
    var counter = 0
    var prevIndex = -1
    
    for i in 0..<string.count{
        if counter < word.count{
            if string[i] == word[counter]{
                if prevIndex == -1 {
                    prevIndex = i
                    counter = counter + 1
                    index = i
                } else {
                    if i-1 == prevIndex{
                        prevIndex = i
                        counter = counter + 1
                    } else {
                        prevIndex = -1
                        counter = 0
                        index = -1
                    }
                }
            } else {
                if counter == 0{
                } else {
                    prevIndex = -1
                    counter = 0
                    index = -1
                }
            }
        }
    }
    return index
}


struct Schedule{
    
    var courses: [Course] = [Course]()
    
    var user: User!
    
    
    init(_ innerHTML: Any?) throws {
        
        if let decodedUser = UserDefaults.standard.object(forKey: "User") as? Data{
            user = (NSKeyedUnarchiver.unarchiveObject(with: decodedUser) as! User)
        }
        
        guard let htmlString = innerHTML as? String else {throw HTMLError.badInnerHTML}
        
        var tableContent = [[String]]()
        let doc = try SwiftSoup.parse(htmlString)
        
        var elements: Array<Element>
        
        if user.identity == .teacher{
            let classes = try! doc.getElementById("teacherSectionTable")
            elements = (try! classes?.select("tr").array())!
        } else {
            let classes = try! doc.getElementsByClass("linkDescList grid")
            elements = try! classes.select("td").array()
        }
        
        
        
        var nColumn:(Int,Int){
            if user.school.name == .TsinghuaInternationalSchool{
                if user.identity == .student{
                    return (20,15)
                } else {
                    return (10,1)
                }
            } else {
                return (14,11)
            }
        }
        
        
        
        for i in 0..<(elements.count/nColumn.0){
            var rowContent = [String]()
            for j in 0..<nColumn.0{
                if j==0 || j==nColumn.1{
                    let colContent = try! elements[(i*nColumn.0)+j].text()
                    rowContent.append(colContent)
                    print("WOEWWWWWW")
                }
            }
            tableContent.append(rowContent)
        }
    
        
        
        for clas in tableContent{
            
            if user.school.name == .TsinghuaInternationalSchool{
                if clas[0].prefix(2)=="HR" || clas[0].prefix(3)=="EHR"{
                } else {
                    // put clas inside of courses array
                    
                    var time = clas[0]
                    print("time \(time)")
                    var spaces = indexOf(character: " ", text: time)
                    
                    var days: [String] = [String]()
                    
                    for i in 0..<spaces.count{
                        days.append(String(time.prefix(spaces[i])))
                        time = time.substring(from: spaces[i])
                    }
                    
                    days.append(time)
                    
                    
                    var nums:[Int] = [Int]()
                    
                    for day in days{
                        
                        var periods: [Int] = [Int]()
                        var sum = 0
                        var reachedParen = false
                        var counter = 0
                        
                        var consecutiveClass = false
                        var consecutiveStartDay = 0
                        
                        for char in day{
                            if char=="("{
                                reachedParen = true
                                periods.append(sum)
                                counter += 1
                                sum = 0
                            }else if char=="-" && reachedParen == false {
                                periods.append(sum)
                                counter += 1
                                sum = 0
                            }else if char=="-" && reachedParen == true{
                                consecutiveClass = true
                            }else if reachedParen==false{
                                sum = sum + intValue(char: char)
                            }else if char == ")"{
                            } else {
                                if char == "," {
                                    consecutiveClass = false
                                } else {
                                    for i in 0..<periods.count{
                                        nums.append(periods[i]+Int(String(char))!*100)
                                    }
                                    if consecutiveClass == false{
                                        consecutiveStartDay = Int(String(char))!
                                    }
                                    if consecutiveClass == true{
                                        for i in 0..<periods.count{
                                            for k in consecutiveStartDay+1..<Int(String(char))!{
                                                nums.append(periods[i]+Int(k*100))
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }
                        
                    }
                    
                    var room = ""
                    var name = ""
                    var teacher = ""
                    
                    if user.identity == .student{
                        let roomIndex = indexBeforeWord(word: "Rm:", string: clas[1])+4
                        let courseEndIndex = indexBeforeWord(word: "Details", string: clas[1])
                        let teacherStartIndex = indexBeforeWord(word: "Details", string: clas[1])+14
                        let teacherEndIndex = indexBeforeWord(word: "Email", string: clas[1])-1
                        
                        room = String(clas[1][roomIndex...])
                        name = String(clas[1][0..<courseEndIndex])
                        teacher = String(clas[1][teacherStartIndex..<teacherEndIndex])
                    } else {
                        name = String(clas[1])
                    }
                    
                    
                    // put in the class
                    
                    for num in nums{
                        print("coursename: \(name)")
                        let clday = ClassDay(days: [String(num/100)], period: String(num%10), part: (num/10)%10)
                        let course = Course(name: name, teacher: teacher, room: room, day: clday)
                        courses.append(course)
                    }
                    
                }

            } else {
                
                
                // ISB
                let rotation = clas[0]
                print("rotation: \(rotation)")
                var period = ""
                var days = [String]()
                
                var hasReachedParenthesis = false
                var hasExitParenthesis = false
                
                for char in rotation{
                    if hasExitParenthesis == false{
                        if char != "(" && char != ")"{
                            if hasReachedParenthesis == false{
                                period = period + String(char)
                            } else {
                                if char != "-" && char != ","{
                                    days.append(String(char))
                                }
                            }
                        } else {
                            if char == "("{
                                hasReachedParenthesis = true
                            } else {
                                hasExitParenthesis = true
                            }
                        }
                    }
                }
                
                print("days \(days.count)")
                
                if days.count != 0{
                
                    let roomIndex = indexBeforeWord(word: "Rm:", string: clas[1])+4
                    let courseEndIndex = indexBeforeWord(word: "Details", string: clas[1])
                    let teacherStartIndex = indexBeforeWord(word: "Details", string: clas[1])+14
                    let teacherEndIndex = indexBeforeWord(word: "Email", string: clas[1])-1
                
                
                
                    let room = clas[1][roomIndex..<clas[1].count]
                    let name = clas[1][0..<courseEndIndex]
                    let teacher = clas[1][teacherStartIndex..<teacherEndIndex]
                    print("coursename: \(name)")
                    courses.append(Course(name: String(name), teacher: String(teacher), room: String(room), day: ClassDay(days: days, period: period, part: 0)))
                    print(name)
                }
            }
            
        }
    }
    
    
}
