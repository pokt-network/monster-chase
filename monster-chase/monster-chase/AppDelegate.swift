//
//  AppDelegate.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/23/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import CoreData
import Pocket
import BigInt
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, Configuration, UNUserNotificationCenterDelegate {
    var nodeURL: URL {
        get {
            //return URL.init(string: "https://aion.pokt.network")!
            //return URL.init(string: "http://localhost:3000")!
            return URL.init(string: "http://192.168.0.155:3000")!
        }
    }

    var window: UIWindow?
    
    static var shared = {
        return UIApplication.shared.delegate as! AppDelegate
    }()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // Setup background fetch interval: Fetch data once an hour.
        UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
        
        // Setup notifications
        UNUserNotificationCenter.current().delegate = self
        PushNotificationUtils.requestPermissions(successHandler: nil, errorHandler: nil)
        
        // Pocket configuration
        Pocket.shared.setConfiguration(config: self)
        
        // Refresh app data
        self.updatePlayerAndQuestData(completionHandler: refreshCurrentViewController)
        
        // Setup repeating tasks
        self.setupRepeatingTasks()
        
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

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "monster_chase")
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
    
    // MARK: - Background refresh
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.updatePlayerAndQuestData {
            completionHandler(.newData)
        }
    }
    
    // MARK: - Local data updates
    func updatePlayer(completionHandler: @escaping (_ playerAddress: String) -> Void) {
        do {
            let player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
            if let playerAddress = player.address {
                print("Player Address: \(playerAddress)")
                var godfatherAdddress: String? = nil
                if let godfatherWallet = player.getGodfatherWallet() {
                    godfatherAdddress = godfatherWallet.address
                    print("Godfather Address: \(godfatherWallet.address)")
                }
                let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, monsterTokenAddress: AppConfiguration.monsterTokenAddress, godfatherAddress: godfatherAdddress)
                appInitQueueDispatcher.initDispatchSequence {
                    completionHandler(playerAddress)
                }
            }
        } catch {
            print("\(error)")
        }
    }
    
    func updateChaseList(playerAddress: String, completionHandler: @escaping () -> Void) {
        let chaseListQueueDispatcher = AllChasesQueueDispatcher.init(monsterTokenAddress: AppConfiguration.monsterTokenAddress, playerAddress: playerAddress)
        chaseListQueueDispatcher.initDispatchSequence(completionHandler: completionHandler)
    }
    
    func updatePlayerAndQuestData(completionHandler: @escaping () -> Void) {
        updatePlayer { (playerAddress) in
            self.updateChaseList(playerAddress: playerAddress, completionHandler: completionHandler)
        }
    }
    
    // MARK: - Utils
    public func refreshCurrentViewController() {
        UIApplication.getPresentedViewController(handler: { (topVC) in
            if topVC == nil {
                print("Failed to get current view controller")
            } else {
                do {
                    try topVC!.refreshView()
                }catch let error as NSError {
                    print("Failed to refresh current view controller with error: \(error)")
                }
            }
        })
    }
    
    func setupRepeatingTasks() {
        let notificationTitle = "MONSTER CHASE"
        
        let questCreationTimer = ChaseNotificationTimer.init(timeInterval: 10, title: notificationTitle, successMsg: "Your Chase has been created successfully", errorMsg: "An error ocurred creating your Chase, please try again", successIdentifier: "ChaseCreationSuccess", errorIdentifier: "ChaseCreationError", txType: TransactionType.creation, maxRetries: 75)
        questCreationTimer.resume()
        let questClaimTimer = ChaseNotificationTimer.init(timeInterval: 10, title: notificationTitle, successMsg: "Your Monster has been claimed succesfully", errorMsg: "An error ocurred claiming your Monster, please try again", successIdentifier: "ChaseClaimSuccess", errorIdentifier: "ChaseClaimError", txType: TransactionType.claim, maxRetries: 75)
        questClaimTimer.resume()
    }

}

