//
//  DownloadOwnersTokenCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadOwnersTokenCountOperationError: Error {
    case totalOwnerTokenParsing
}

public class DownloadOwnersTokenCountOperation: AsynchronousOperation {
    
    public var leaderboardRecord: LeaderboardRecord?
    public var ownerIndex: BigInt
    public var monsterTokenAddress: String
    
    public init(monsterTokenAddress: String, ownerIndex:BigInt) {
        self.monsterTokenAddress = monsterTokenAddress
        self.ownerIndex = ownerIndex
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = DownloadOwnersCountOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        monsterToken.getOwnerTokenCountByIndex(ownerIndex: ownerIndex, handler: { (results, error) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            print("\(results)")
            self.finish()
        })
    }
}
