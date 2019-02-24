//
//  DownloadOwnersCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/2/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadOwnersCountOperationError: Error {
    case totalOwnerParsing
    case monsterTokenInitError
}

public class DownloadOwnersCountOperation: AsynchronousOperation {
    
    var total: BigInt?
    public var monsterTokenAddress: String
    
    
    public init(monsterTokenAddress: String) {
        self.monsterTokenAddress = monsterTokenAddress
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = DownloadOwnersCountOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        monsterToken.getOwnersCount { (results, error) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let totalHexString = results?.first as? String else {
                self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                self.finish()
                return
            }

            guard let totalHexStringParsed = HexStringUtil.removeLeadingZeroX(hex: totalHexString) else{
                self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                self.finish()
                return
            }

            guard let totalAmount = BigInt.init(totalHexStringParsed, radix: 16) else {
                self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                self.finish()
                return
            }

            self.total = totalAmount
            self.finish()
        }
    }
}
