//
//  AppInitQueueDispatcher.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import BigInt

public class AppInitQueueDispatcher: QueueDispatcherProtocol {
    
    private let operationQueue: OperationQueue = OperationQueue()
    private let downloadBalanceOperation: DownloadBalanceOperation
    private let downloadGodfatherBalanceOperation: DownloadBalanceOperation?
    private let transactionCountOperation: DownloadTransactionCountOperation
    private let chaseAmountOperation: DownloadChaseAmountOperation
    private let aionUsdPriceOperation: DownloadAionUsdPriceOperation
    private var completionHandler: QueueDispatcherCompletionHandler?
    
    public init(playerAddress: String, monsterTokenAddress: String, godfatherAddress: String?) {
        // Init operations
        self.downloadBalanceOperation = DownloadBalanceOperation.init(address: playerAddress)
        if let godfatherAddress = godfatherAddress {
            self.downloadGodfatherBalanceOperation = DownloadBalanceOperation.init(address: godfatherAddress)
        } else {
            self.downloadGodfatherBalanceOperation = nil
        }
        self.transactionCountOperation = DownloadTransactionCountOperation.init(address: playerAddress)
        self.chaseAmountOperation = DownloadChaseAmountOperation.init()
        self.aionUsdPriceOperation = DownloadAionUsdPriceOperation.init()
        self.setOperationsCompletionBlocks()
    }
    
    public func initDispatchSequence(completionHandler: QueueDispatcherCompletionHandler?) {
        print("Initializing AppInitQueueDispatcher sequence")
        self.completionHandler = completionHandler
        var operations = [self.downloadBalanceOperation, self.transactionCountOperation, self.chaseAmountOperation, self.aionUsdPriceOperation]
        if let godfatherBalanceOperation = downloadGodfatherBalanceOperation {
            operations.append(godfatherBalanceOperation)
        }
        self.operationQueue.addOperations(operations, waitUntilFinished: false)
    }
    
    public func isQueueFinished() -> Bool {
        return self.operationQueue.operations.reduce(into: true) { (result, currOperation) in
            if currOperation.isFinished == false {
                result = false
            }
        }
    }
    
    public func cancelAllOperations() {
        self.operationQueue.cancelAllOperations()
    }
    
    // Private interfaces
    private func attempToExecuteCompletionHandler() {
        if self.isQueueFinished() {
            if let completionHandler = self.completionHandler {
                completionHandler()
            }
            
            var godfatherBalanceAmp: BigInt? = nil
            if let godfatherBalanceOperation = self.downloadGodfatherBalanceOperation {
                godfatherBalanceAmp = godfatherBalanceOperation.balance
            }
            
            // Update the player record
            self.operationQueue.addOperations([UpdatePlayerOperation.init(balanceAmp: self.downloadBalanceOperation.balance, transactionCount: self.transactionCountOperation.transactionCount, questAmount: self.chaseAmountOperation.chaseAmount, aionUsdPrice: self.aionUsdPriceOperation.usdPrice, godfatherBalanceAmp: godfatherBalanceAmp)], waitUntilFinished: false)
        }
    }
    
    private func setOperationsCompletionBlocks() {
        self.downloadBalanceOperation.completionBlock = {
            print("Completed downloadBalanceOperation")
            self.attempToExecuteCompletionHandler()
        }
        
        self.transactionCountOperation.completionBlock = {
            print("Completed transactionCountOperation")
            self.attempToExecuteCompletionHandler()
        }
        
        self.chaseAmountOperation.completionBlock = {
            print("Completed chaseAmountOperation")
            self.attempToExecuteCompletionHandler()
        }
        
        self.aionUsdPriceOperation.completionBlock = {
            print("Completed aionUsdPriceOperation")
            self.attempToExecuteCompletionHandler()
        }
        
        if let downloadGodfatherBalanceOperation = self.downloadGodfatherBalanceOperation {
            downloadGodfatherBalanceOperation.completionBlock = {
                print("Completed downloadGodfatherBalanceOperation")
                self.attempToExecuteCompletionHandler()
            }
        }
    }
}

