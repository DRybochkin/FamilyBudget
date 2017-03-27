//
//  AppDelegate.swift
//  FamilyBudget
//
//  Created by Dmitry Rybochkin on 28.12.16.
//  Copyright © 2016 Dmitry Rybochkin. All rights reserved.
//
//  Посмотреть, какие решения существуют по VIPER и реализовать проект на ней
//

import AlamofireNetworkActivityIndicator
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //TODO show alert and shutdown

        NetworkActivityIndicatorManager.shared.isEnabled = true

        if (SQLiteDataStore.sharedInstance.initDatabase()) {
            registerForPushNotifications(application)

            SynchronizeHelper.synchronizeWithServer(needPost: false)
        }

        NotificationCenter.default.addObserver(self, selector: #selector(synchronize(_:)), name: NSNotification.Name.FamilyBudgetDidChangeData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectAndSynchronize), name: NSNotification.Name.FamilyBudgetDidChangeOptions, object: nil)

        return true
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
        NotificationCenter.default.post(name: Notification.Name(rawValue: "FamilyBudgetWillEnterForeground"), object: nil)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
    }

    /*Push notifications*/
    func registerForPushNotifications(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            let center = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.badge, .alert, .sound]) { (granted, _) in
                if (granted) {
                    application.registerForRemoteNotifications()
                }
            }
        } else {
            let type: UIUserNotificationType = [UIUserNotificationType.badge, UIUserNotificationType.alert, UIUserNotificationType.sound]
            let setting = UIUserNotificationSettings(types: type, categories: nil)
            application.registerUserNotificationSettings(setting)
        }
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""

        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }

        print("didRegisterForRemoteNotificationsWithDeviceToken => \(token)")
        SQLiteDataStore.sharedInstance.options.notificationToken = token
        _ = DOOptionsDataHelper.update(item: SQLiteDataStore.sharedInstance.options)
        if (SQLiteDataStore.sharedInstance.currentUser.userGroupKeyword.characters.isEmpty) {
            ServerImplementation.sharedInstance.connectToServer(user: SQLiteDataStore.sharedInstance.currentUser, callback: nil)
        }
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

    }

    @available(*, deprecated: 10.0)
    func application(_ application: UIApplication, didRegister notificationSettings: UIUserNotificationSettings) {
        if (!application.isRegisteredForRemoteNotifications || SQLiteDataStore.sharedInstance.options.notificationToken == "") {
            application.registerForRemoteNotifications()
        }
    }

    //@available(iOS 10.0, *)
    //TODO добавить методы для ios 10

    /*DataStore synchronixe with server*/
    func synchronize(_ notification: NSNotification) {
        SynchronizeHelper.upload(needPost: false, callback: {
            SynchronizeHelper.download()
        })
    }

    func connectAndSynchronize() {
        SynchronizeHelper.synchronizeWithServer()
    }

}
