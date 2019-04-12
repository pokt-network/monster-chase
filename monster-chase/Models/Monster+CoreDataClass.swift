//
//  Monster+CoreDataClass.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData
import BigInt

public enum MonsterError: Error {
    case invalidIndex
}

@objc(Monster)
public class Monster: NSManagedObject {
    convenience init(chase: Chase, context: NSManagedObjectContext) throws {
        self.init(context: context)
        try self.replaceValues(chase: chase)
    }
    
    // Updates chase instance with dict
    public func replaceValues(chase: Chase) throws {
        
        if !chase.name.isEmpty {
            self.name = chase.name
        }else{
            self.name = ""
        }
        
        if !chase.hexColor.isEmpty {
            self.hexColor = chase.hexColor
        } else {
            self.hexColor = ""
        }
        
        guard let chaseIndex = chase.index else {
            throw MonsterError.invalidIndex
        }
        
        self.index = chaseIndex
    }
    
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    func reset() throws {
        self.managedObjectContext?.reset()
    }
    
    func delete() throws {
        self.managedObjectContext?.delete(self)
        try self.save()
    }
    
    public static func dropTable(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Monster")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try context.execute(request)
    }
    
    public static func sortedMonstersByIndex(context: NSManagedObjectContext) throws -> [Monster] {
        let fetchRequest: NSFetchRequest<Monster> = Monster.fetchRequest()
        let sort = NSSortDescriptor.init(key: "index", ascending: false, selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sort]
        return try context.fetch(fetchRequest) as [Monster]
    }
    
    public static func exists(monsterIndex: String, context: NSManagedObjectContext) -> Bool {
        var result = false
        let fetchRequest: NSFetchRequest<Monster> = Monster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "index == %@", monsterIndex)
        do {
            let results = try context.fetch(fetchRequest) as [Monster]
            if results.count > 0 {
                result = true
            }
        } catch {
            result = false
        }
        
        return result
    }
    
    public static func getMonsterByIndex(monsterIndex: String, context: NSManagedObjectContext) -> Monster? {
        var result: Monster?
        let fetchRequest: NSFetchRequest<Monster> = Monster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "index == %@", monsterIndex)
        
        do {
            let results = try context.fetch(fetchRequest) as [Monster]
            if results.count >= 1 {
                result = results.first
            }
        } catch {
            result = nil
        }
        
        return result
    }
    
    func getLocalMonsterCount(context: NSManagedObjectContext) throws -> Int64 {
        var monsters = [Monster]()
        
        let fetchRequest = NSFetchRequest<Monster>(entityName: "Monster")
        
        monsters = try context.fetch(fetchRequest) as [Monster]
        
        return Int64(monsters.count)
    }
    
}
