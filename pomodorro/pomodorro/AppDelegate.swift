//
//  AppDelegate.swift
//  pomodorro
//
//  Created by Владимир on 22/10/2018.
//  Copyright © 2018 ult_v. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let notificationManager = NotificationManager()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let viewController = window!.rootViewController as! ViewController
        viewController.notificationManager = notificationManager
        // Override point for customization after application launch.
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        notificationManager.removeAllReminders()
    }


}

