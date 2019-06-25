//
//  WalkthroughViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/6/11.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit
import AVOSCloud

class WalkthroughViewController: UIViewController,UITableViewDataSource,UITableViewDelegate  {

    @IBOutlet weak var headingLabel:UILabel!
    @IBOutlet weak var subHeadingLabel:UILabel!
    @IBOutlet weak var contentImageView:UIImageView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var schoolTableView: UITableView!
    @IBOutlet weak var studentButton: UIButton!
    @IBOutlet weak var teacherButton: UIButton!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var schoolTitle: UILabel!
    @IBOutlet weak var studentTitle: UILabel!
    
    var identity: String = ""
    var selectedSchool: String = ""
    
    var index : Int = 0
    var heading : String = ""
    var imageFile : String = ""
    var subHeading : String = ""
    
    
    let schools = ["Tsinghua International School","International School of Beijing"]
    
    var selectedSchools = [Bool](repeating: false, count: 3)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        headingLabel.text = heading
        subHeadingLabel.text = subHeading
        contentImageView.image = UIImage(named: imageFile)
        pageControl.currentPage = index
        view.backgroundColor = .white
        
        if index <= 1{
            titleLabel.isHidden = true
            schoolTitle.isHidden = true
            studentTitle.isHidden = true
            teacherButton.isHidden = true
            studentButton.isHidden = true
            schoolTableView.isHidden = true
            checkButton.isHidden = true
        }else{
            pageControl.isHidden = true
            contentImageView.isHidden = true
            headingLabel.isHidden = true
            subHeadingLabel.isHidden = true
            schoolTableView.delegate = self
            schoolTableView.dataSource = self
            schoolTableView.backgroundColor = .clear
            checkButton.isEnabled = false
            
            studentButton.setTitle("Student", for: .normal)
            teacherButton.setTitle("Teacher", for: .normal)
            studentButton.layer.borderWidth = 2.0
            teacherButton.layer.borderWidth = 2.0
            studentButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
            teacherButton.layer.borderColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
            studentButton.layer.cornerRadius = 25.0
            teacherButton.layer.cornerRadius = 25.0
            
            studentButton.setTitleColor(.black, for: .normal)
            teacherButton.setTitleColor(.black, for: .normal)
        }
        
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return schools.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "school", for: indexPath) as! SchoolTableViewCell
        cell.schoolNameLabel.text = schools[indexPath.section]
        cell.layer.borderWidth = 2.0
        cell.layer.borderColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0).cgColor
        cell.layer.cornerRadius = 30.0
        if selectedSchools[indexPath.section] == true{
            cell.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
            cell.schoolNameLabel.textColor = .white
        }else{
            cell.backgroundColor = .white
            cell.schoolNameLabel.textColor = .black
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
        return 60.0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedSchools[indexPath.section] = true
        for i in 0..<schools.count{
            if i != indexPath.section{
                selectedSchools[i] = false
            }
        }
        selectedSchool = (tableView.cellForRow(at: indexPath) as! SchoolTableViewCell).schoolNameLabel.text!
        
        schoolTableView.reloadData()
        if identity != ""{
            checkButton.isEnabled = true
        }
    }
    
    @IBAction func checkStudent(_ sender: Any) {
        identity = "Student"
        studentButton.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        studentButton.setTitleColor(.white, for: .normal)
        if teacherButton.titleColor(for: .normal) == .white{
            teacherButton.setTitleColor(.black, for: .normal)
            teacherButton.backgroundColor = .white
        }
        if selectedSchool != ""{
            checkButton.isEnabled = true
        }
    }
    
    @IBAction func checkTeacher(_ sender: Any) {
        identity = "Teacher"
        teacherButton.backgroundColor = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        teacherButton.setTitleColor(.white, for: .normal)
        if studentButton.titleColor(for: .normal) == .white{
            studentButton.setTitleColor(.black, for: .normal)
            studentButton.backgroundColor = .white
        }
        if selectedSchool != ""{
            checkButton.isEnabled = true
        }
    }
    
    @IBAction func check(_ sender: Any) {
        
        print("I am a \(identity) from \(selectedSchool)")
        
        if identity == "Teacher" && selectedSchool != "Tsinghua International School"{
            let alertController = UIAlertController(title: "Unavalible", message: "Sorry, but we do not support accounts of \(identity) in \(selectedSchool).", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(alertController, animated: true, completion: nil)
        }else{
            
            // set up user and save to user defaults
            print("selected school: \(selectedSchool)")
            let school = School(holidays: nil, calendar: nil,name:selectedSchool)
            
            let user = User(school: school, identity: Identity(rawValue: identity)!, schedule: nil,clubs:nil,grades: nil)
            // save user
            saveObject(user, forKey: "User")
            
            
            let currentInstallation = AVInstallation.current()
            currentInstallation.setObject(user.school.name.rawValue, forKey: "school")
            currentInstallation.setObject(user.identity.rawValue, forKey: "identity")
            currentInstallation.saveInBackground()
            if user.school.name == .TsinghuaInternationalSchool{
                dismiss(animated: true, completion: nil)
            }else{
                self.performSegue(withIdentifier: "walkthrough", sender: self)
            }
        }
    }
    
    
    // MARK: - Helper Methods
    public func saveObject(_ object: Any, forKey key: String){
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
        userDefaults.set(encodedData, forKey: key)
        userDefaults.synchronize()
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
