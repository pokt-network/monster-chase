//
//  DownloadOwnersTokenCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

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
        
        monsterToken.getOwnerTokenCountByIndex(ownerIndex: ownerIndex, handler: { (error, results) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            print("\(results)")
            
            guard let leaderboardEntry = results else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            
            guard let player = leaderboardEntry.first as? String else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            
            guard let tokenCount = leaderboardEntry.last as? String else {
                self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                self.finish()
                return
            }
            
            self.leaderboardRecord = LeaderboardRecord.init(address: player, tokenTotal: BigInt.init(tokenCount) ?? BigInt.init(0))
            self.finish()
        })
    }
}
