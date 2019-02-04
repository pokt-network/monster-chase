//
//  Player+CoreDataProperties.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData


extension Player {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Player> {
        return NSFetchRequest<Player>(entityName: "Player")
    }

    @NSManaged public var address: String?
    @NSManaged public var balanceWei: String?
    @NSManaged public var aionUsdPrice: Double
    @NSManaged public var tavernMonsterAmount: String?
    @NSManaged public var transactionCount: String?

}
