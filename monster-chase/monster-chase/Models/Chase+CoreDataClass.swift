//
//  Chase+CoreDataClass.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData
import BigInt
import MapKit

public extension BigInt {
    public static func anyToBigInt(anyValue: Any) -> BigInt?{
        if let strValue = anyValue as? String {
            return BigInt.init(strValue)
        } else if let intValue = anyValue as? Int {
            return BigInt.init(intValue)
        } else {
            return nil
        }
    }
}

@objc(Chase)
public class Chase: NSManagedObject {
    convenience init(obj: [AnyHashable: Any], context: NSManagedObjectContext) throws {
        self.init(context: context)
        self.replaceValues(obj: obj)
    }
    
    // Updates the chase instance with dict
    public func replaceValues(obj: [AnyHashable: Any]) {
        _ = obj.map { (key, value) -> Void in
            switch key as? String {
            case "index":
                self.index = String.init(BigInt.anyToBigInt(anyValue: value) ?? BigInt.init(0))
            case "creator":
                self.creator = value as? String ?? ""
            case "name":
                self.name = value as? String ?? ""
            case "hint":
                self.hint = value as? String ?? ""
            case "maxWinners":
                self.maxWinners = String.init(BigInt.anyToBigInt(anyValue: value) ?? BigInt.init(0))
            case "prize":
                self.prize = String.init(BigInt.anyToBigInt(anyValue: value) ?? BigInt.init(0))
            case "merkleRoot":
                self.merkleRoot = value as? String ?? ""
            case "merkleBody":
                self.merkleBody = value as? String ?? ""
            case "winnersAmount":
                self.winnersAmount = String.init(BigInt.anyToBigInt(anyValue: value) ?? BigInt.init(0))
            case "claimersAmount":
                self.claimersAmount = String.init(BigInt.anyToBigInt(anyValue: value) ?? BigInt.init(0))
            case "isWinner":
                self.winner = value as? Bool ?? false
            case "isClaimer":
                self.claimer = value as? Bool ?? false
            case "valid":
                self.valid = value as? Bool ?? false
            case "metadata":
                if let metadata = value as? String {
                    self.metadata = metadata
                    let metaElements = metadata.split(separator: ",").map { (substring) -> String in
                        return String.init(substring)
                    }
                    
                    if metaElements.count == 9 {
                        self.hexColor = metaElements[0]
                        self.lat1 = Float(metaElements[1]) ?? 0.0
                        self.lon1 = Float(metaElements[2]) ?? 0.0
                        self.lat2 = Float(metaElements[3]) ?? 0.0
                        self.lon2 = Float(metaElements[4]) ?? 0.0
                        self.lat3 = Float(metaElements[5]) ?? 0.0
                        self.lon3 = Float(metaElements[6]) ?? 0.0
                        self.lat4 = Float(metaElements[7]) ?? 0.0
                        self.lon4 = Float(metaElements[8]) ?? 0.0
                    }
                }
            case "distance":
                self.distance = 0.0
            case .none:
                return
            case .some(_):
                return
            }
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
    
    public static func chasesWonByPlayer(context: NSManagedObjectContext) throws -> [Chase] {
        let fetchRequest: NSFetchRequest<Chase> = Chase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "winner == YES")
        let sort = NSSortDescriptor(key: #keyPath(Chase.index), ascending: false)
        fetchRequest.sortDescriptors = [sort]
        return try context.fetch(fetchRequest) as [Chase]
    }
    
    public static func sortedChasesByIndex(context: NSManagedObjectContext) throws -> [Chase] {
        let fetchRequest: NSFetchRequest<Chase> = Chase.fetchRequest()
        let sort = NSSortDescriptor.init(key: "index", ascending: false, selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sort]
        return try context.fetch(fetchRequest) as [Chase]
    }
    
    public static func sortedChasesByNearest(context: NSManagedObjectContext, userLocation: CLLocation) throws -> [Chase] {
        let fetchRequest: NSFetchRequest<Chase> = Chase.fetchRequest()
        let sort = NSSortDescriptor.init(key: "index", ascending: false, selector: #selector(NSString.localizedStandardCompare))
        fetchRequest.sortDescriptors = [sort]
        
        let chaseList = try context.fetch(fetchRequest) as [Chase]
        
        for chase in chaseList {
            chase.distance = LocationUtils.chaseDistanceToPlayerLocation(chase: chase, playerLocation: userLocation)
        }
        
        return chaseList.sorted(by: { $0.distance < $1.distance })
    }
    
    public static func getchaseByIndex(chaseIndex: String, context: NSManagedObjectContext) -> Chase? {
        var result: Chase?
        let fetchRequest: NSFetchRequest<Chase> = Chase.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "index == %@", chaseIndex)
        
        do {
            let results = try context.fetch(fetchRequest) as [Chase]
            if results.count == 1 {
                result = results.first
            }
        } catch {
            result = nil
        }
        
        return result
    }
    
    func getLocalChaseCount(context: NSManagedObjectContext) throws -> Int64{
        var chases = [Chase]()
        
        let fetchRequest = NSFetchRequest<Chase>(entityName: "Chase")
        
        chases = try context.fetch(fetchRequest) as [Chase]
        
        return Int64(chases.count)
    }
    
    public static func retrieveChaseList(handler: @escaping ChaseListCompletionHandler) throws {
        // Chases list retrieved from CoreData
        var chases = [Chase]()
        
        let fetchRequest = NSFetchRequest<Chase>(entityName: "Chase")
        
        do {
            chases = try CoreDataUtils.mainPersistentContext.fetch(fetchRequest) as [Chase]
            handler(chases,nil)
        }
        catch let error as NSError {
            handler(nil,error)
        }
        
    }
    
    func dictionary() -> [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["index"] = index
        dict["creator"] = creator
        dict["name"] = name
        dict["prize"] = prize
        dict["hint"] = hint
        dict["maxWinners"] = maxWinners
        dict["merkleRoot"] = merkleRoot
        dict["merkleBody"] = merkleBody
        dict["metadata"] = metadata
        dict["winnersAmount"] = winnersAmount
        dict["claimersAmount"] = claimersAmount
        dict["winner"] = winner
        dict["claimer"] = claimer
        dict["distance"] = distance
        
        return dict
    }
    
    func getQuadranHintCorners() -> [CLLocation] {
        let point1 = CLLocation.init(latitude: Double.init(self.lat1), longitude: Double.init(self.lon1))
        let point2 = CLLocation.init(latitude: Double.init(self.lat2), longitude: Double.init(self.lon2))
        let point3 = CLLocation.init(latitude: Double.init(self.lat3), longitude: Double.init(self.lon3))
        let point4 = CLLocation.init(latitude: Double.init(self.lat4), longitude: Double.init(self.lon4))
        return [point1, point2, point3, point4]
    }
    
    func getCreatorHexAddress() -> String {
        return "0x\(creator ?? "")"
    }
}

