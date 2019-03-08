//
//  ChaseCreationTimer.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/30/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public class ChaseNotificationTimer: RepeatingTimer {
    
    private var title: String
    private var successMsg: String
    private var errorMsg: String
    private var successIdentifier: String
    private var errorIdentifier: String
    private var txType: TransactionType
    private var maxRetries: Int64
    
    init(timeInterval: TimeInterval, title: String, successMsg: String, errorMsg: String, successIdentifier: String, errorIdentifier: String, txType: TransactionType, maxRetries: Int64) {
        self.title = title
        self.successMsg = successMsg
        self.errorMsg = errorMsg
        self.successIdentifier = successIdentifier
        self.errorIdentifier = errorIdentifier
        self.txType = txType
        self.maxRetries = maxRetries
        super.init(timeInterval: timeInterval)
        self.eventHandler = self.notifyPendingQuestTransactions
    }
    
    private func notifyPendingQuestTransactions() {
        var transactions:[Transaction]
        do {
            transactions = try Transaction.unnotifiedTransactionsPerType(context: CoreDataUtils.backgroundPersistentContext, txType: self.txType, maxRetries: self.maxRetries)
        } catch {
            print("\(error)")
            return
        }
        
        let operationQueue = OperationQueue.init()
        var operations = [DownloadTransactionReceiptOperation]()
        
        for transaction in transactions {
            if transaction.txHash == nil {
                print("Error retrieving txHash")
                return
            }
            
            let txReceiptOperation = DownloadTransactionReceiptOperation.init(txHash: transaction.txHash! )
            txReceiptOperation.completionBlock = {
                if txReceiptOperation.error != nil {
                    print("Error downloading txreceipt with hash: \(txReceiptOperation.txHash)")
                    transaction.retries = transaction.retries + 1
                    if (transaction.retries > self.maxRetries) {
                        self.notifyTransaction(title: self.title, body: self.errorMsg, identifier: self.errorIdentifier, transaction: transaction)
                    } else {
                        do {
                            try transaction.save()
                        } catch {
                            print("\(error)")
                        }
                    }
                    return
                }
                
                if let txReceipt = txReceiptOperation.txReceipt {
                    if txReceipt.status == .success {
                        self.notifyTransaction(title: self.title, body: self.successMsg, identifier: self.successIdentifier, transaction: transaction)
                    } else {
                        self.notifyTransaction(title: self.title, body: self.errorMsg, identifier: self.errorIdentifier, transaction: transaction)
                    }
                }
            }
            operations.append(txReceiptOperation)
        }
        
        if !operations.isEmpty {
            operationQueue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
    private func notifyTransaction(title: String, body: String, identifier: String, transaction: Transaction) {
        PushNotificationUtils.sendNotification(title: title, body: body, identifier: identifier)
        do {
            transaction.notified = true
            try transaction.save()
        } catch {
            print("\(error)")
        }
    }
    
}
