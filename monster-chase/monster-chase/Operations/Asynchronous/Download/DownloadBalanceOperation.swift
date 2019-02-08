//
//  DownloadBalanceOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import Pocket
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
        
        do {
            try PocketAion.eth.getBalance(address: address, subnetwork: AppConfiguration.subnetwork, blockTag: BlockTag.init(block: .LATEST), handler: { (result, error) in
                if error != nil {
                    self.error = error
                    self.finish()
                    return
                }
                
                self.balance = result
                self.finish()
            })
        } catch {
            self.error = error
            self.finish()
        }
        
    }
}

