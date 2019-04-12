//
//  PlayerBalanceQueueDispatcher.swift
//  monster-chase
//
//  Created by Luis De Leon on 3/11/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
//
//  PlayerBalanceQueueDispatcher.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import BigInt

public typealias PlayerBalanceQueueDispatcherCompletionHandler = (BigInt, BigInt) -> Void

// TODO conform to protocol
public class PlayerBalanceQueueDispatcher {
    
    private let operationQueue: OperationQueue = OperationQueue()
    private let downloadBalanceOperation: DownloadBalanceOperation
    private let downloadGodfatherBalanceOperation: DownloadBalanceOperation?
    private var completionHandler: PlayerBalanceQueueDispatcherCompletionHandler
    
    public init(playerAddress: String, godfatherAddress: String?, completionHandler: @escaping PlayerBalanceQueueDispatcherCompletionHandler) {
        print("Initializing PlayerBalanceQueueDispatcher sequence")
        // Init operations
        self.downloadBalanceOperation = DownloadBalanceOperation.init(address: playerAddress)
        if let godfatherAddress = godfatherAddress {
            self.downloadGodfatherBalanceOperation = DownloadBalanceOperation.init(address: godfatherAddress)
        } else {
            self.downloadGodfatherBalanceOperation = nil
        }
        self.completionHandler = completionHandler
        var operations = [self.downloadBalanceOperation]
        if let godfatherBalanceOperation = downloadGodfatherBalanceOperation {
            operations.append(godfatherBalanceOperation)
        }
        self.setOperationsCompletionBlocks()
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
            let playerBalanceAmp: BigInt = self.downloadBalanceOperation.balance ?? BigInt.init(0)
            
            let godfatherBalanceAmp: BigInt
            if let godfatherBalanceOperation = self.downloadGodfatherBalanceOperation {
                godfatherBalanceAmp = godfatherBalanceOperation.balance ?? BigInt.init(0)
            } else {
                godfatherBalanceAmp = BigInt.init(0)
            }
            
            self.completionHandler(playerBalanceAmp, godfatherBalanceAmp)
        }
    }
    
    private func setOperationsCompletionBlocks() {
        self.downloadBalanceOperation.completionBlock = {
            print("Completed downloadBalanceOperation")
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


