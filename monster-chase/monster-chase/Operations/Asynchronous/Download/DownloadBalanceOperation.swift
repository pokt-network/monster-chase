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
        let params = [
            "rpcMethod": "eth_getBalance",
            "rpcParams": [address, "latest"]
            ] as [AnyHashable: Any]
        
        guard let query = try? PocketAion.createQuery(subnetwork: AppConfiguration.subnetwork, params: params, decoder: nil) else {
            self.error = PocketPluginError.queryCreationError("Error creating query")
            self.finish()
            return
        }
        
        Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let balanceHex: String = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
                self.error = DownloadBalanceOperationError.responseParsing
                self.finish()
                return
            }
            
            guard let balance = BigInt(balanceHex, radix: 16) else {
                self.error = DownloadBalanceOperationError.responseParsing
                self.finish()
                return
            }
            
            self.balance = balance
            self.finish()
        }
    }
}

