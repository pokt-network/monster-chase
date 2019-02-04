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

@objc(Monster)
public class Monster: NSManagedObject {
    convenience init(obj: Chase, context: NSManagedObjectContext) throws {
        self.init(context: context)
        self.replaceValues(obj: obj, context: context)
    }
    
    // Updates chase instance with dict
    public func replaceValues(obj: Chase, context: NSManagedObjectContext) {
        
        if !obj.name.isEmpty {
            self.name = obj.name
        }else{
            self.name = ""
        }
        
        if !obj.hexColor.isEmpty {
            self.hexColor = obj.hexColor
        }else{
            self.hexColor = ""
        }
        
        do {
            let bananosCount = try getLocalMonsterCount(context: context)
            self.index = String.init(BigInt.anyToBigInt(anyValue: bananosCount) ?? BigInt.init(0))
            
        } catch let error as NSError {
            print("Failed with error: \(error)")
        }
        
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
    
    public static func sortedMonstersByIndex(context: NSManagedObjectContext) throws -> [Monster] {
        let fetchRequest: NSFetchRequest<Monster> = Monster.fetchRequest()
        let sort = NSSortDescriptor.init(key: "index", ascending: false, selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sort]
        return try context.fetch(fetchRequest) as [Monster]
    }
    
    public static func getMonstersByIndex(monsterIndex: String, context: NSManagedObjectContext) -> Monster? {
        var result: Monster?
        let fetchRequest: NSFetchRequest<Monster> = Monster.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "index == %@", monsterIndex)
        
        do {
            let results = try context.fetch(fetchRequest) as [Monster]
            if results.count == 1 {
                result = results.first
            }
        } catch {
            result = nil
        }
        
        return result
    }
    
    func getLocalMonsterCount(context: NSManagedObjectContext) throws -> Int64{
        var monsters = [Monster]()
        
        let fetchRequest = NSFetchRequest<Monster>(entityName: "Monster")
        
        monsters = try context.fetch(fetchRequest) as [Monster]
        
        return Int64(monsters.count)
    }
    
}
