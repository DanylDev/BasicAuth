//
//  AppDelegate.swift
//  Drink App
//
//  Created by Denis Yakovenko on 2/1/19.
//  Copyright © 2019 Denis Yakovenko. All rights reserved
//

import UIKit
import CoreData
import GoogleMaps
import Stripe
import Fabric
import Crashlytics
import SideMenu
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, OSSubscriptionObserver {

    #if DEBUG
    let baseUrl = "https://dev-manage.drinkapp.net/"
//    let baseUrl = "http://local.drink.app/"
    let stripeKey = "pk_test_oi5OtvRAF4qnGy6zqYjXqXvG"
    
    #elseif DEVELOPMENT
    let baseUrl = "https://dev-manage.drinkapp.net/"
    let stripeKey = "pk_test_oi5OtvRAF4qnGy6zqYjXqXvG"
    
    #elseif STAGING
    let baseUrl = "https://staging-manage.drinkapp.net/"
    let stripeKey = "pk_test_oi5OtvRAF4qnGy6zqYjXqXvG"
    
    #elseif PRODUCTION
    let baseUrl = "https://manage.drinkapp.net/"
    let stripeKey = "pk_live_olPN2zDr74TLBcEKhJ1bZ1k9"
    
    #endif
    
    var transactionFee = 3    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        UIApplication.shared.statusBarStyle = .lightContent
        
        GMSServices.provideAPIKey("AIzaSyAduOnmBGeS7MTOREPwMNGGHouG9dOf8xc")
        
        STPPaymentConfiguration.shared().publishableKey = self.stripeKey
        
        Fabric.with([STPAPIClient.self, Crashlytics.self])
        
        SideMenuManager.default.menuEnableSwipeGestures = false
        
        let onesignalInitSettings = [kOSSettingsKeyAutoPrompt: false]
        
        OneSignal.initWithLaunchOptions(launchOptions,
                                        appId: "6e329c50-74f3-458b-85a1-e8cb79de7cff",
                                        handleNotificationAction: nil,
                                        settings: onesignalInitSettings)
        
        OneSignal.inFocusDisplayType = OSNotificationDisplayType.notification;
        OneSignal.add(self as OSSubscriptionObserver)
        
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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // After you add the observer on didFinishLaunching, this method will be called when the notification subscription property changes.
    func onOSSubscriptionChanged(_ stateChanges: OSSubscriptionStateChanges!) {
        if !stateChanges.from.subscribed && stateChanges.to.subscribed {
            print("Subscribed for OneSignal push notifications!")
        }
        print("SubscriptionStateChange: \n\(stateChanges)")
        
        //The player id is inside stateChanges. But be careful, this value can be nil if the user has not granted you permission to send notifications.
        if let playerId = stateChanges.to.userId {
            print("Current playerId \(playerId)")
            let userDefaults = UserDefaults.standard
            userDefaults.set(playerId, forKey: "onesignal_playerid")
            userDefaults.synchronize()
            
            Networking.sharedInstance.userOneSignal(playerId: playerId, completion: { (success, error) in
                
            })
        }
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Drink_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

