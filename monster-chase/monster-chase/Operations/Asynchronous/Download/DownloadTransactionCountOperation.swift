//
//  DownloadTransactionCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift
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
        guard let aionNetwork = PocketAion.shared?.defaultNetwork else {
            self.error = DownloadTransactionCountOperationError.responseParsing
            self.finish()
            return
        }
        
        aionNetwork.eth.getTransactionCount(address: address, blockTag: nil, callback: { (error, result) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            self.transactionCount = result
            self.finish()
        }) 
    }
}

