//
//  DownloadChaseOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

import BigInt
import SwiftyJSON

public enum DownloadChaseOperationError: Error {
    case chaseParsing
    case monsterTokenInitError
}

public class DownloadChaseOperation: AsynchronousOperation {
    
    public var chaseIndex: BigInt
    public var chaseDict: [AnyHashable: Any]?
    
    public init(chaseIndex: BigInt) {
        self.chaseIndex = chaseIndex
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = DownloadChaseOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        monsterToken.getChaseHeader(chaseIndex: chaseIndex) { (error, results) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let chaseHeaderResults = results else {
                self.error = DownloadChaseOperationError.chaseParsing
                self.finish()
                return
            }
            
            if chaseHeaderResults.count != 6 {
                self.error = DownloadChaseOperationError.chaseParsing
                self.finish()
                return
            }
            
            monsterToken.getChaseDetail(chaseIndex: self.chaseIndex, handler: { (detailError, detailResults) in
                if let detailError = detailError {
                    self.error = detailError
                    self.finish()
                    return
                }
                
                guard let chaseDetailResults = detailResults else {
                    self.error = DownloadChaseOperationError.chaseParsing
                    self.finish()
                    return
                }
                
                if chaseDetailResults.count != 3 {
                    self.error = DownloadChaseOperationError.chaseParsing
                    self.finish()
                    return
                }
                
                // Start building the chase
                // Index
                let index = String(self.chaseIndex)
                // Merkle Body
                // Header
                let creator = chaseHeaderResults[0] as? String ?? ""
                let name = chaseHeaderResults[1] as? String ?? ""
                let hint = chaseHeaderResults[2] as? String ?? ""
                let maxWinners = chaseHeaderResults[3] as? String ?? "0"
                let metadata = chaseHeaderResults[4] as? String ?? ""
                let valid = chaseHeaderResults[5] as? Bool ?? false
                // Details
                let merkleRoot = chaseDetailResults[0] as? String ?? ""
                let merkleBody = chaseDetailResults[1] as? String ?? ""
                let winnersAmount = chaseDetailResults[2] as? String ?? "0"
                
                self.chaseDict = [
                    "creator": creator,
                    "index": index,
                    "name": name,
                    "hint": hint,
                    "merkleRoot": merkleRoot,
                    "merkleBody": merkleBody,
                    "maxWinners": maxWinners,
                    "metadata": metadata,
                    "valid": valid,
                    "winnersAmount": winnersAmount
                    ] as [AnyHashable: Any]
                self.finish()
            })
        }
    }
}
