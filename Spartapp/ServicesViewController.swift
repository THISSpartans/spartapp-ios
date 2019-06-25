//
//  ServicesViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/9/11.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit

class ServicesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    @IBOutlet weak var servicesTableView: UITableView!
    
    let services:[(String,String)] = [("Speech Showcase Election 2019","election"),("StuCo 2018 Election","election")]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        servicesTableView.delegate = self
        servicesTableView.dataSource = self
        
        servicesTableView.backgroundColor = .clear
        servicesTableView.rowHeight = 179.0
        
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = true
        } else {
            // Fallback on earlier versions
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return services.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ServiceTableViewCell
        cell.bgImageView.image = UIImage(named: services[indexPath.section].1)
        cell.titleLabel.text = services[indexPath.section].0
        cell.layer.cornerRadius = 14.0
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let screenSize = UIScreen.main.bounds
        let screenHeight = screenSize.height
        return (30/402)*screenHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 1{
            
            let alertController = UIAlertController(title: "Sorry", message: "Election is over.", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: {
            })
        }else{
            let defaults = UserDefaults.standard
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM-dd-yyyy HH:mm"
            let now = dateFormatter.string(from: NSDate() as Date)
            
            print(now)

            if Int(now[0...1])! == 3 && Int(now[3...4])! == 29 && Int(now[11...12])! >= 11 && Int(now[11...12])! <= 15{
                
                if let decodedVotingStatus = defaults.object(forKey: "Vote") as? Data{
                    // has voted
                    
                    let alertController = UIAlertController(title: "Sorry", message: "You have already  voted", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertController, animated: true, completion: {
                        
                    })
                    
                }else{
                    performSegue(withIdentifier: "toVote", sender: self)
                }
                
            }else{
                
                let alertController = UIAlertController(title: "Sorry", message: "Voting takes place between 11:00-15:00 on March 29th, 2019 (Beijing Time)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: {
                    
                    
                })
            }
            
            
            
        }
    }
    
    
    // MARK: - Navigation
    
    @IBAction func unwindToServices(segue:UIStoryboardSegue){}

}
