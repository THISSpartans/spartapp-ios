//
//  SendNotificationViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/12/20.
//  Copyright © 2018 童开文. All rights reserved.
//

//  How the hell does this view load??????

import UIKit
import AVOSCloud

class SendNotificationViewController: UIViewController {

    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 242.0/255.0, green: 242.0/255.0, blue: 242.0/255.0, alpha: 1.0)
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func send(_ sender: Any) {
        let push = AVPush()
        AVPush.setProductionMode(false)
        push.setPushToAndroid(true)
        push.setPushToIOS(true)
        push.setMessage("This is a test")
        push.sendInBackground()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
