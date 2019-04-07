//
//  DownloadBalanceOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift
import BigInt

public enum DownloadBalanceOperationError: Error {
    case responseParsing
}

public class DownloadBalanceOperation: AsynchronousOperation {
    
    public var address: String
    public var balance: BigInt?
    
    public init(address: String) {
        self.address = address
        super.init()
    }
    
    open override func main() {
        
        guard let aionNetwork = PocketAion.shared?.defaultNetwork else {
            self.error = DownloadBalanceOperationError.responseParsing
            self.finish()
            return
        }
        
        aionNetwork.eth.getBalance(address: address, blockTag: nil, callback: { (error, result) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            self.balance = result
            self.finish()
        })
        
    }
}

