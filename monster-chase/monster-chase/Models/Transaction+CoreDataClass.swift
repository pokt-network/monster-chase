//
//  Transaction+CoreDataClass.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData

public enum TransactionType: String {
    case creation = "creation"
    case claim = "claim"
}

@objc(Transaction)
public class Transaction: NSManagedObject {
    
    // MARK: - Init
    convenience init(txHash: String, type: TransactionType, context: NSManagedObjectContext) {
        self.init(context: context)
        self.type = type.rawValue
        self.txHash = txHash
        self.notified = false
        self.retries = 0
    }
    
    // MARK: - CRUD
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    public static func dropTable(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Transaction")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try context.execute(request)
    }
    
    // MARK: - Convenience list retrieval
    public static func unnotifiedTransactionsPerType(context: NSManagedObjectContext, txType: TransactionType, maxRetries: Int64) throws -> [Transaction] {
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "notified == NO AND type == %@", txType.rawValue)
        return try context.fetch(fetchRequest) as [Transaction]
    }
    
}

