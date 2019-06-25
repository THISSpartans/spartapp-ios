//
//  PageWTViewController.swift
//  Spartapp
//
//  Created by 童开文 on 2018/6/11.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit

class PageWTViewController: UIPageViewController, UIPageViewControllerDataSource {

    var pageHeadings = ["Schedule", "Announcement", "Hello World"]
    var pageImages = ["schedule", "announcement", "fiveleaves"]
    var pageSubHeadings = ["Your personal schedule, at your fingertips; Your classes, more attractive than ever.", "Announcements, anywhere, anytime; Notifications, don’t miss out important messages ever again.", "Hello"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        dataSource = self
        // Create the first walkthrough screen
        if let startingViewController = self.viewControllerAtIndex(index: 0) {
            setViewControllers([startingViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index = index - 1
        return self.viewControllerAtIndex(index: index)
        
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = (viewController as! WalkthroughViewController).index
        index = index + 1
        return self.viewControllerAtIndex(index: index)
        
    }
    
    func viewControllerAtIndex(index: Int) -> WalkthroughViewController? {
        if index == NSNotFound || index < 0 || index >= self.pageHeadings.count {
            return nil
        }
        // Create a new view controller and pass suitable data.
        if let pageContentViewController = storyboard?.instantiateViewController(withIdentifier: "PageContentViewController") as? WalkthroughViewController {
            
            pageContentViewController.imageFile = pageImages[index]
            pageContentViewController.heading = pageHeadings[index]
            pageContentViewController.subHeading = pageSubHeadings[index]
            pageContentViewController.index = index
            return pageContentViewController
            
        }
        return nil
    }

}
