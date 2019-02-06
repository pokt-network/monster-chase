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
            return URL.init(string: "https://aion.pokt.network")!
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

        // Test data
        do {
            let chaseCount = try Chase.getLocalChaseCount(context: CoreDataUtils.mainPersistentContext)
            
            if chaseCount == 0 {
                let chase1 = try Chase.init(obj: [AnyHashable : Any](), context: CoreDataUtils.mainPersistentContext)
                chase1.index = "1"
                chase1.creator = "0x000000000000000000000"
                chase1.name = "Tu Cuquito"
                chase1.maxWinners = String.init(BigInt.init("10"))
                chase1.hint = "The monster is somewhere"
                chase1.merkleBody = "80ee139f275e9293e53fe583070aaa2400abaf706abd4cf059525542a652d294,5662a6b8fdd3d39bf9bcb33dc4f0b3708e4a1cff976ffdee37f6a28a8dc773b9-1949d17173bf812d88b610c5d9ad80aceec8094c34b82b92e97f806c62c2c7e2,0465c94440a1f9029a049f9b04ff951587badc8c3342c552be4c39faa73177fc,19b47e7d2ff53e6f8f6cd87be19dcf7882996f7a9670ac7ad938801fa5bf8a4b,14c12491d98676499de078d5bd2c4a2c9711bdd6b1118c78d003a15b78408120-9ddded6330d850645f33e2cdbf476fe87188ffca1324072b8357f0d2a0ff9369,30bdf536cce4ff6bf3f3d2c8a8c22ed979c7541f95021a520929cf0ec4977e90,203fd956f245fb5cdab4898404ca7f38c515496b071053763cfb85606e8c287a,37248ad3b756fe68aa1cc8bc5ea1f901c52f3429d1d840ccb40b72024a808b65,ca60fa22b233f4b73398706d36aa493090986d684f18448a26553c317f039f34,70d4058ce8d828f12023501799fccb439be316c496252ba4a5196a51a11ab070,7881d2d7f1aa034e52dfb6c8816af792d402fe9f9b61c3885753f7bac20178f9,1db1446de87f0066c0cf4030cf94a21b0b3231e8abb07594305f9654baca4903"
                chase1.merkleRoot = "0xb0a9f0bc95874c04384544c951e780bcb755f22f29a92efe1be8b3cc8c2b60e9"
                chase1.hexColor = "FF0016"
                chase1.lat1 = 18.47435601
                chase1.lon1 = -69.97488952
                chase1.lat2 = 18.47435601
                chase1.lon2 = -69.97129224
                chase1.lat3 = 18.47795329
                chase1.lon3 = -69.97488952
                chase1.lat3 = 18.47795329
                chase1.lon4 = -69.97129224
                
                try chase1.save()
                
                ///
                let chase2 = try Chase.init(obj: [AnyHashable : Any](), context: CoreDataUtils.mainPersistentContext)
                chase2.index = "2"
                chase2.creator = "0x000000000000000000000"
                chase2.name = "Tu Cuquito #2"
                chase2.maxWinners = String.init(BigInt.init("10"))
                chase2.hint = "The monster is somewhere 2"
                chase2.merkleBody = "80ee139f275e9293e53fe583070aaa2400abaf706abd4cf059525542a652d294,5662a6b8fdd3d39bf9bcb33dc4f0b3708e4a1cff976ffdee37f6a28a8dc773b9-1949d17173bf812d88b610c5d9ad80aceec8094c34b82b92e97f806c62c2c7e2,0465c94440a1f9029a049f9b04ff951587badc8c3342c552be4c39faa73177fc,19b47e7d2ff53e6f8f6cd87be19dcf7882996f7a9670ac7ad938801fa5bf8a4b,14c12491d98676499de078d5bd2c4a2c9711bdd6b1118c78d003a15b78408120-9ddded6330d850645f33e2cdbf476fe87188ffca1324072b8357f0d2a0ff9369,30bdf536cce4ff6bf3f3d2c8a8c22ed979c7541f95021a520929cf0ec4977e90,203fd956f245fb5cdab4898404ca7f38c515496b071053763cfb85606e8c287a,37248ad3b756fe68aa1cc8bc5ea1f901c52f3429d1d840ccb40b72024a808b65,ca60fa22b233f4b73398706d36aa493090986d684f18448a26553c317f039f34,70d4058ce8d828f12023501799fccb439be316c496252ba4a5196a51a11ab070,7881d2d7f1aa034e52dfb6c8816af792d402fe9f9b61c3885753f7bac20178f9,1db1446de87f0066c0cf4030cf94a21b0b3231e8abb07594305f9654baca4903"
                chase2.merkleRoot = "0xb0a9f0bc95874c04384544c951e780bcb755f22f29a92efe1be8b3cc8c2b60e9"
                chase2.hexColor = "FF0016"
                chase2.lat1 = 18.47435601
                chase2.lon1 = -69.97488952
                chase2.lat2 = 18.47435601
                chase2.lon2 = -69.97129224
                chase2.lat3 = 18.47795329
                chase2.lon3 = -69.97488952
                chase2.lat3 = 18.47795329
                chase2.lon4 = -69.97129224
                
                try chase2.save()
            }
        } catch  {
            print(error)
        }
        
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
                let appInitQueueDispatcher = AppInitQueueDispatcher.init(playerAddress: playerAddress, tavernAddress: AppConfiguration.tavernAddress, monsterTokenAddress: AppConfiguration.monsterTokenAddress)
                appInitQueueDispatcher.initDispatchSequence {
                    completionHandler(playerAddress)
                }
            }
        } catch {
            print("\(error)")
        }
    }
    
    func updateChaseList(playerAddress: String, completionHandler: @escaping () -> Void) {
        let chaseListQueueDispatcher = AllChasesQueueDispatcher.init(tavernAddress: AppConfiguration.tavernAddress, monsterTokenAddress: AppConfiguration.monsterTokenAddress, playerAddress: playerAddress)
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
        
        let questCreationTimer = QuestNotificationTimer.init(timeInterval: 60, title: notificationTitle, successMsg: "Your Quest has been created successfully", errorMsg: "An error ocurred creating your Quest, please try again", successIdentifier: "QuestCreationSuccess", errorIdentifier: "QuestCreationError", txType: TransactionType.creation)
        questCreationTimer.resume()
        let questClaimTimer = QuestNotificationTimer.init(timeInterval: 60, title: notificationTitle, successMsg: "Your BANANO has been claimed succesfully", errorMsg: "An error ocurred claiming your BANANO, please try again", successIdentifier: "QuestClaimSuccess", errorIdentifier: "QuestClaimError", txType: TransactionType.claim)
        questClaimTimer.resume()
    }

}

