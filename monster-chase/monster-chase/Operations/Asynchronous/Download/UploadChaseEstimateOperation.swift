//
//  UploadChaseEstimateOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import struct Pocket.Wallet
import BigInt
import SwiftyJSON

public enum UploadChaseEstimateOperationError: Error {
    case resultParsing
    case tavernInitializationError
}

public class UploadChaseEstimateOperation: AsynchronousOperation {
    
    public var estimatedGas: BigInt?
    public var chaseName: String
    public var hint: String
    public var maxWinners: BigInt
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var playerAddress: String
    
    public init(playerAddress: String, chaseName: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String) {
        self.chaseName = chaseName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.playerAddress = playerAddress
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = UploadChaseEstimateOperationError.tavernInitializationError
            self.finish()
            return
        }
        
        guard let submitChaseCallData = monsterToken.submitChaseCallData(player: self.playerAddress, name: self.chaseName, hint: self.hint, maxWinners: self.maxWinners, merkleRoot: self.merkleRoot, merkleBody: self.merkleBody, metadata: self.metadata) else {
            self.error = UploadChaseEstimateOperationError.tavernInitializationError
            self.finish()
            return
        }
        
        try? PocketAion.eth.estimateGas(to: monsterToken.address, fromAddress: self.playerAddress, nrg: nil, nrgPrice: AppConfiguration.nrgPrice, value: BigInt.init(0), data: submitChaseCallData, subnetwork: AppConfiguration.subnetwork, blockTag: BlockTag.init(block: BlockTag.DefaultBlock.LATEST)) { (estimate, error) in
            
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            if let estimate = estimate {
                self.estimatedGas = estimate
                self.finish()
            } else {
                self.error = UploadChaseEstimateOperationError.resultParsing
                self.finish()
                return
            }
        }
    }
}
