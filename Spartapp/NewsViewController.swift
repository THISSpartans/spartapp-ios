//
//  NewsViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/11/29.
//  Copyright © 2018 童开文. All rights reserved.
//

import UIKit
import LeanCloud

class News {
    var title: String
    var body: String
    var day: Int
    var weekday: String
    var hasShadow: Bool
    
    init (title: String, body: String, day: Int, weekday: String, hasShadow: Bool){
        self.title = title
        self.body = body
        self.day = day
        self.weekday = weekday
        self.hasShadow = hasShadow
    }
}



class NewsViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {

    @IBOutlet weak var newsTableView: UITableView!
    
    var news: [News] = [News]()
    
    var daysBefore = 2
    
    var refreshControl = UIRefreshControl()
    
    var weekdayNames:[String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        newsTableView.delegate = self
        newsTableView.dataSource = self
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
        
        
        fetchNews(untilDate: dateBefore(days: daysBefore))
        
        
        refreshControl.attributedTitle = NSAttributedString(string: "")
        refreshControl.addTarget(self, action: #selector(self.refresh(sender:)), for: UIControl.Event.valueChanged)
        newsTableView.addSubview(refreshControl)
        
        // add 1 to views
        
        let query = LCQuery(className: "NewsViews")
        
        let date = currentDate()
        
        var year: Int{
            if date.0 < 8{
                return 2019
            }else{
                return 2018
            }
        }
        
        
        var dateString = "\(year)"
        if (date.0<10){
            dateString += "0\(date.0)"
        }else{
            dateString += "\(date.0)"
        }
        if (date.1<10){
            dateString += "0\(date.1)"
        }else{
            dateString += "\(date.1)"
        }
        
        query.whereKey("date", .equalTo(dateString))
        query.find { (result) in
            switch result{
            case .success(let objects):
                print(objects.count)
                if objects.count != 0{
                    let objectID = objects[0].get("objectId")?.stringValue!
                    let todayViews = LCObject(className: "NewsViews", objectId: objectID!)
                    todayViews.increase("numOfViews", by: 1)
                    
                    todayViews.save { result in
                        switch result {
                        case .success:
                        break // 更新成功
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
            case .failure(let error):
                print(error)
                print("got it")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        newsTableView.estimatedRowHeight = 115
        newsTableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @objc func refresh(sender:AnyObject) {
        // Code to refresh table view
        fetchNews(untilDate: dateBefore(days: 3))
        daysBefore = 0
    }
    
    func fetchNews(untilDate date: String){
        
        // get current date
        
        
        let limitingDate = (Int(date[6...9])!*10000) + (Int(date[0...1])!*100) + (Int(date[3...4])!)
        
        print(limitingDate)
        
        let query = LCQuery(className: "News")
        query.whereKey("date", .greaterThanOrEqualTo(limitingDate))
        query.whereKey("date", .descending)
        
        query.find { result in
            switch result {
            case .success(let objects):
                
                print("objects count \(objects.count)")
                
                self.news.removeAll()
                
                let firstDate = (objects[0].get("date")?.intValue)!
                var dateString = String(firstDate)
                var dayNum = Int(dateString[6...7])!
                var dateFormatted = "\(dateString[0...3])-\(dateString[4...5])-\(dateString[6...7])"
                var weekd = self.weekdayNames[self.getDayOfWeek(dateFormatted)!-1]
                
                
                self.news.append(News(title: "", body: "sdfghjkdfghjkdfghjkdfghjksdfghjkdfghjkdfghjkdfghjk", day: dayNum, weekday: weekd, hasShadow: false))
                
                for i in 0..<objects.count{
                    if i > 0 && objects[i].get("date")?.intValue != objects[i-1].get("date")?.intValue{
                        
                        dateString = String(objects[i].get("date")!.intValue!)
                        dayNum = Int(dateString[6...7])!
                        dateFormatted = "\(dateString[0...3])-\(dateString[4...5])-\(dateString[6...7])"
                        weekd = self.weekdayNames[self.getDayOfWeek(dateFormatted)!-1]
                        
                        self.news.append(News(title: "", body: "sdfghjkdfghjkdfghjkdfghjksdfghjkdfghjkdfghjkdfghjk", day: dayNum, weekday: weekd, hasShadow: false))
                    }
                    let new = News(title: (objects[i].get("title")?.stringValue)!, body: (objects[i].get("body")?.stringValue)!, day: 0, weekday: "", hasShadow: true)
                    self.news.append(new)
                }
                
                DispatchQueue.main.async {
                    self.newsTableView.reloadData()
                    self.refreshControl.endRefreshing()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    // refresh when scrolled to the bottom
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // Notify interested parties that end has been reached

            daysBefore += 3
            print(daysBefore)
            if daysBefore <= 30{
                fetchNews(untilDate: dateBefore(days: daysBefore))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (news.count)
    }
    
    func convert(day:Int)->String{
        if day == 0{
            return ""
        }else{
            return String(day)
        }
    }
    
    func returnColor(hasShadow: Bool)->UIColor{
        if hasShadow{
            return .black
        }else{
            return .clear
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NewsTableViewCell
        
        cell.titleLabel.text = news[indexPath.section].title
        cell.newsLabel.text = news[indexPath.section].body
        cell.dayLabel.text = convert(day: news[indexPath.section].day)
        cell.weekdayLabel.text = news[indexPath.section].weekday
        cell.newsBackgroundView.backgroundColor = .white
        cell.newsBackgroundView.isHidden = !news[indexPath.section].hasShadow
        cell.newsLabel.textColor = returnColor(hasShadow: news[indexPath.section].hasShadow)
        
        if indexPath.section == 0 && currentDate().1 == news[indexPath.section].day {
            cell.dayLabel.textColor = School.color[.TsinghuaInternationalSchool]
            cell.weekdayLabel.textColor = School.color[.TsinghuaInternationalSchool]
        }
        

        return cell
        
    }
    
    func dateBefore(days: Int)->String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        return dateFormatter.string(from: NSDate().addingTimeInterval(TimeInterval(-days*24*60*60)) as Date)
    }
    
    func getDayOfWeek(_ today:String) -> Int? {
        let formatter  = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let todayDate = formatter.date(from: today) else { return nil }
        let myCalendar = Calendar(identifier: .gregorian)
        let weekDay = myCalendar.component(.weekday, from: todayDate)
        return weekDay
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return (10/667)*screenHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func currentDate()->(Int,Int){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
        let now = dateFormatter.string(from: NSDate() as Date)
        return (Int(now[0...1])!,Int(now[3...4])!)
    }

}
