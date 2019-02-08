//
//  DownloadTransactionCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import Pocket
import BigInt

public enum DownloadTransactionCountOperationError: Error {
    case responseParsing
}

public class DownloadTransactionCountOperation: AsynchronousOperation {
    
    public var address: String
    public var transactionCount: BigInt?
    
    public init(address: String) {
        self.address = address
        super.init()
    }
    
    open override func main() {
        
        do {
            try PocketAion.eth.getTransactionCount(address: address, subnetwork: AppConfiguration.subnetwork, blockTag: BlockTag.init(block: .LATEST), handler: { (result, error) in
                if error != nil {
                    self.error = error
                    self.finish()
                    return
                }
                
                self.transactionCount = result
                self.finish()
            })
        } catch {
            self.error = error
            self.finish()
        }
        
    }
}

