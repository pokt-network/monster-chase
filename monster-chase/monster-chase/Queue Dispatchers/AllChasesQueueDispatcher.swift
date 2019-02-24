//
//  AllChasesQueueDispatcher.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import BigInt

public class AllChasesQueueDispatcher: QueueDispatcherProtocol {
    
    private var completionHandler: QueueDispatcherCompletionHandler?
    private var currentChaseIndex: BigInt?
    private var tavernChaseAmount: BigInt?
    private let monsterTokenAddress: String
    private let operationQueue = OperationQueue.init()
    private let playerAddress: String
    private var isWinnerOperations: [DownloadAndUpdateChaseIsWinnerOperation] = [DownloadAndUpdateChaseIsWinnerOperation]()
    
    public init(monsterTokenAddress: String, playerAddress: String) {
        self.monsterTokenAddress = monsterTokenAddress
        self.operationQueue.maxConcurrentOperationCount = 1
        self.playerAddress = playerAddress
    }
    
    public func initDispatchSequence(completionHandler: QueueDispatcherCompletionHandler?) {
        self.completionHandler = completionHandler
        let chaseAmountOperation = DownloadChaseAmountOperation.init()
        chaseAmountOperation.completionBlock = {
            self.tavernChaseAmount = chaseAmountOperation.chaseAmount
            if let tavernChaseAmount = self.tavernChaseAmount {
                self.currentChaseIndex = tavernChaseAmount - 1
                self.processNextQuest()
            }
        }
        self.operationQueue.addOperations([chaseAmountOperation], waitUntilFinished: false)
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
            
            if !self.isWinnerOperations.isEmpty {
                // Don't need to wait for these operations to complete
                self.operationQueue.maxConcurrentOperationCount = 10
                self.operationQueue.addOperations(self.isWinnerOperations, waitUntilFinished: false)
            }
        }
    }
    
    private func processNextQuest() {
        guard let currentChaseIndex = self.currentChaseIndex else {
            self.attempToExecuteCompletionHandler()
            return
        }
        if currentChaseIndex < 0 {
            self.attempToExecuteCompletionHandler()
            return
        }
        
        let downloadChaseOperation = DownloadChaseOperation.init(chaseIndex: currentChaseIndex)
        
        downloadChaseOperation.completionBlock = {
            self.currentChaseIndex = currentChaseIndex - 1
            
            if downloadChaseOperation.finishedSuccesfully {
                if let chaseDict = downloadChaseOperation.chaseDict {
                    let updateQuestOperation = UpdateChaseOperation.init(chaseDict: chaseDict, chaseIndex: String.init(currentChaseIndex))
                    updateQuestOperation.completionBlock = {
                        self.attempToExecuteCompletionHandler()
                        
                        if let chaseIndexStr = chaseDict["index"] as? String {
                            if let chaseIndexBigInt = BigInt.init(chaseIndexStr) {
                                let isWinnerOperation = DownloadAndUpdateChaseIsWinnerOperation.init(chaseIndex: chaseIndexBigInt, alledgedWinner: self.playerAddress)
                                self.isWinnerOperations.append(isWinnerOperation)
                            }
                        }
                    }
                    self.operationQueue.addOperation(updateQuestOperation)
                }
            }
            self.processNextQuest()
        }
        
        self.operationQueue.addOperations([downloadChaseOperation], waitUntilFinished: false)
    }
}
