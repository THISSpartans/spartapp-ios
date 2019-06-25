//
//  SSVoteViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2019/3/27.
//  Copyright © 2019 童开文. All rights reserved.
//

import UIKit
import LeanCloud

class SSVoteViewController: UIViewController {

    @IBOutlet weak var candidateImageView: UIImageView!
    
    @IBOutlet weak var pdfWebView: UIWebView!
    
    @IBOutlet weak var republicanButton: UIButton!
    
    @IBOutlet weak var democraticButton: UIButton!
    
    @IBOutlet weak var voteButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        republican(self)
    }
    
    
    @IBAction func republican(_ sender: Any) {
        
        republicanButton.setTitleColor(.black, for: .normal)
        
        democraticButton.setTitleColor(.lightGray, for: .normal)
        
        candidateImageView.image = UIImage(named: "joannaHe")
        
        let targetURL = Bundle.main.url(forResource: "republicanManifesto", withExtension: "pdf")!
        let request = NSURLRequest(url: targetURL)
        pdfWebView.loadRequest(request as URLRequest)
        
        voteButton.setTitle("Vote Joanna He", for: .normal)
    }
    
    @IBAction func democratic(_ sender: Any) {
        
        democraticButton.setTitleColor(.black, for: .normal)
        
        republicanButton.setTitleColor(.lightGray, for: .normal)
        
        candidateImageView.image = UIImage(named: "kimberlyLiu")
        
        let targetURL = Bundle.main.url(forResource: "democraticManifesto", withExtension: "pdf")!
        let request = NSURLRequest(url: targetURL)
        pdfWebView.loadRequest(request as URLRequest)
        
        voteButton.setTitle("Vote Kimberly Liu", for: .normal)
    }
    
    @IBAction func vote(_ sender: Any){
        
        let vote = LCObject(className: "Langelection2019")
        
        vote.set("studentID", value: "iOS")
        
        
        if voteButton.title(for: .normal) == "Vote Joanna He"{
            vote.set("party", value: true)
        }else{
            vote.set("party",value: false)
        }
        
        
        vote.save { result in
            switch result {
            case .success:
                self.saveObject("voted", forKey: "Vote")
                self.performSegue(withIdentifier: "backServices", sender: self)
            case .failure(_):
                
                let alertController = UIAlertController(title: "Something went wrong", message: "Make sure you have a stable internet connection", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: {
                    
                })
            }
        }
        
        
    }
    
    func saveObject(_ object: Any, forKey key: String){
        let userDefaults = UserDefaults.standard
        let encodedData: Data = NSKeyedArchiver.archivedData(withRootObject: object)
        userDefaults.set(encodedData, forKey: key)
        userDefaults.synchronize()
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
