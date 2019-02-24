//
//  DownloadChaseAmountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadChaseAmountOperationError: Error {
    case amountParsing
}

public class DownloadChaseAmountOperation: AsynchronousOperation {
    
    public var chaseAmount: BigInt?
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = UploadChaseEstimateOperationError.tavernInitializationError
            self.finish()
            return
        }
        
        monsterToken.getChaseAmount { (results, error) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let resultStr = results?.first as? String else {
                self.error = DownloadChaseAmountOperationError.amountParsing
                self.finish()
                return
            }
            
            guard let hexResultBigInt = BigInt.init(resultStr, radix: 10) else {
                self.error = DownloadChaseAmountOperationError.amountParsing
                self.finish()
                return
            }
            
            
            self.chaseAmount = hexResultBigInt
            self.finish()
        }
    }
}

