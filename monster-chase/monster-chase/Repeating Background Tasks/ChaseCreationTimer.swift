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
    
    init(timeInterval: TimeInterval, title: String, successMsg: String, errorMsg: String, successIdentifier: String, errorIdentifier: String, txType: TransactionType) {
        self.title = title
        self.successMsg = successMsg
        self.errorMsg = errorMsg
        self.successIdentifier = successIdentifier
        self.errorIdentifier = errorIdentifier
        self.txType = txType
        super.init(timeInterval: timeInterval)
        self.eventHandler = self.notifyPendingQuestTransactions
    }
    
    private func notifyPendingQuestTransactions() {
        var transactions:[Transaction]
        do {
            transactions = try Transaction.unnotifiedTransactionsPerType(context: CoreDataUtils.backgroundPersistentContext, txType: self.txType)
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
                    return
                }
                
                if let txReceipt = txReceiptOperation.txReceipt {
                    if txReceipt.status == .success {
                        PushNotificationUtils.sendNotification(title: self.title, body: self.successMsg, identifier: self.successIdentifier)
                    } else {
                        PushNotificationUtils.sendNotification(title: self.title, body: self.errorMsg, identifier: self.errorIdentifier)
                    }
                    
                    do {
                        transaction.notified = true
                        try transaction.save()
                    } catch {
                        print("\(error)")
                    }
                }
            }
            operations.append(txReceiptOperation)
        }
        
        if !operations.isEmpty {
            operationQueue.addOperations(operations, waitUntilFinished: false)
        }
    }
    
}
