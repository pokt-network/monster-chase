//
//  DownloadTransactionReceiptOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/30/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift
import BigInt

public enum DownloadTransactionReceiptOperationError: Error {
    case responseParsing
}

public class DownloadTransactionReceiptOperation: AsynchronousOperation {
    
    public var txHash: String
    public var txReceipt: TransactionReceipt?
    
    public init(txHash: String) {
        self.txHash = txHash
        super.init()
    }
    
    open override func main() {
        guard let aionNetwork = PocketAion.shared()?.defaultNetwork else {
            self.error = DownloadTransactionReceiptOperationError.responseParsing
            self.finish()
            return
        }
        
        aionNetwork.eth.getTransactionReceipt(txHash: txHash) { (error, receipt) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            
            guard let receipt = receipt else {
                self.error = DownloadTransactionReceiptOperationError.responseParsing
                self.finish()
                return
            }
            
            self.txReceipt = TransactionReceipt.init(rawReceipt: receipt)
            self.finish()
        }
    }
}

