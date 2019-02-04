//
//  CoreDataUtils.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import CoreData

public enum CoreDataUtilsError: Error {
    case appDelegateError
}

public struct CoreDataUtils {
    
    private static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "monster_chase")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    private static func createManagedObjectContext(mergePolicy: NSMergePolicy, concurrencyType: NSManagedObjectContextConcurrencyType) -> NSManagedObjectContext {
        let persistentContainer = CoreDataUtils.persistentContainer
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType)
        managedObjectContext.persistentStoreCoordinator = persistentContainer.persistentStoreCoordinator
        managedObjectContext.mergePolicy = mergePolicy
        return managedObjectContext
    }
    
    public static var mainPersistentContext: NSManagedObjectContext = {
        return CoreDataUtils.createManagedObjectContext(mergePolicy: .mergeByPropertyObjectTrump, concurrencyType: .mainQueueConcurrencyType)
    }()
    
    public static var backgroundPersistentContext: NSManagedObjectContext = {
        return CoreDataUtils.createManagedObjectContext(mergePolicy: .mergeByPropertyObjectTrump, concurrencyType: .privateQueueConcurrencyType)
    }()
    
    public static func createBackgroundPersistentContext() -> NSManagedObjectContext {
        return CoreDataUtils.createManagedObjectContext(mergePolicy: .mergeByPropertyObjectTrump, concurrencyType: .privateQueueConcurrencyType)
    }
    
}
