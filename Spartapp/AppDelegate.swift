//
//  AppDelegate.swift
//  Spartapp
//
//  Created by 童开文 on 2018/3/12.
//  Copyright © 2018年 童开文. All rights reserved.
//

import UIKit
import LeanCloud
import UserNotifications
import AVOSCloud

enum ShortcutIdentifier: String {
    case updateSchedule
    
    // MARK: Initializers

    init?(fullType: String) {
        guard let last = fullType.components(separatedBy: ".").last else {return nil}
        self.init(rawValue: last)
    }
    
    // MARK: Properties
    
    var type: String {
        return Bundle.main.bundleIdentifier! + ".\(self.rawValue)"
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {

    
    var window: UIWindow?

    /// Saved shortcut item used as a result of an app launch, used later when app is activated.
    var launchedShortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // applicationId 即 App Id，applicationKey 是 App Key
        LeanCloud.initialize(applicationID: "cRxhzMwEQJ07JfRuztRYFJ5n-gzGzoHsz", applicationKey: "kIvYOVL1hGnkS3n1kh76P8NC")
        AVOSCloud.setApplicationId("cRxhzMwEQJ07JfRuztRYFJ5n-gzGzoHsz", clientKey: "kIvYOVL1hGnkS3n1kh76P8NC")
        self.registerForRemoteNotification()
        
        let currentInstallation = AVInstallation.current()
        print("channels \(String(describing: currentInstallation.channels))")
        
        // If a shortcut was launched, display its information and take the appropriate action
        if let shortcutItem = launchOptions?[UIApplication.LaunchOptionsKey.shortcutItem] as?
            UIApplicationShortcutItem {
            
            launchedShortcutItem = shortcutItem
            
        }
        
        
        return true
    }
    
    
    
    func applicationDidBecomeActive(application: UIApplication) {
        guard let shortcut = launchedShortcutItem else { return }
        
        _ = handleShortCutItem(shortcutItem: shortcut)
        
        launchedShortcutItem = nil
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        let handledShortCutItem = handleShortCutItem(shortcutItem: shortcutItem)
        
        completionHandler(handledShortCutItem)
    }
    
    func handleShortCutItem(shortcutItem: UIApplicationShortcutItem) -> Bool {
        
        print("HIIIIIIII")
        // Verify that the provided `shortcutItem`'s `type` is one handled by the application.
        guard ShortcutIdentifier(fullType: shortcutItem.type) != nil else { return false }
        
        guard let shortCutType = shortcutItem.type as String? else { return false }
        
        
        switch (shortCutType) {
        
        case ShortcutIdentifier.updateSchedule.type:
            if self.window!.rootViewController as? UITabBarController != nil {
                let tababarController = self.window!.rootViewController as! UITabBarController
                tababarController.selectedIndex = 0
                guard let nvc = tababarController.selectedViewController as? UINavigationController else {
                    return false
                }
                guard let vc = nvc.viewControllers.first as? ScheduleViewController else {
                    return false
                }
                
                nvc.popToRootViewController(animated: false)
                return vc.openUpdateSchedule(shortcutIdentifier: ShortcutIdentifier.init(fullType: shortcutItem.type)!)
            }
            
            
        default:
            break
        }
        
        
        return true
    }
    
    func registerForRemoteNotification(){
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (granted, error) in
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
                if granted == true{
                    print("授权成功")
                }else{
                    print("授权失败")
                }
            })
            center.getNotificationSettings(completionHandler: { (settings) in
                 /*
                 UNAuthorizationStatusNotDetermined : 没有做出选择
                 UNAuthorizationStatusDenied : 用户未授权
                 UNAuthorizationStatusAuthorized ：用户已授权
                 */
                if settings.authorizationStatus == .notDetermined{
                    print("未选择")
                }else if settings.authorizationStatus == .denied{
                    print("未授权")
                }else if settings.authorizationStatus == .authorized{
                    print("已授权")
                }
            })
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        AVOSCloud.handleRemoteNotifications(withDeviceToken: deviceToken)
        print("device token: \(deviceToken)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("lalala \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        if application.applicationState == .active{
            print("halo")
        }else{
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        let badgeNum = application.applicationIconBadgeNumber
        
        if (badgeNum != 0){
            let installation = AVInstallation.current()
            installation.badge = 0
            installation.saveEventually()
            application.applicationIconBadgeNumber = 0
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
}

