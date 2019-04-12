//
//  Monster+CoreDataProperties.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData


extension Monster {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Monster> {
        return NSFetchRequest<Monster>(entityName: "Monster")
    }

    @NSManaged public var hexColor: String
    @NSManaged public var index: String?
    @NSManaged public var name: String

}
