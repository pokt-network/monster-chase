//
//  Chase+CoreDataProperties.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData

public typealias ChaseListCompletionHandler = (_: [Chase]?, _: Error?) -> Void


extension Chase {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Chase> {
        return NSFetchRequest<Chase>(entityName: "Chase")
    }

    @NSManaged public var claimer: Bool
    @NSManaged public var claimersAmount: String?
    @NSManaged public var creator: String?
    @NSManaged public var distance: Double
    @NSManaged public var hexColor: String
    @NSManaged public var hint: String?
    @NSManaged public var index: String?
    @NSManaged public var lat1: Float
    @NSManaged public var lat2: Float
    @NSManaged public var lat3: Float
    @NSManaged public var lat4: Float
    @NSManaged public var lon1: Float
    @NSManaged public var lon2: Float
    @NSManaged public var lon3: Float
    @NSManaged public var lon4: Float
    @NSManaged public var maxWinners: String?
    @NSManaged public var merkleBody: String?
    @NSManaged public var merkleRoot: String?
    @NSManaged public var metadata: String?
    @NSManaged public var name: String
    @NSManaged public var prize: String?
    @NSManaged public var valid: Bool
    @NSManaged public var winner: Bool
    @NSManaged public var winnersAmount: String?

}
