//
//  UploadChaseEstimateOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

//import struct Pocket.Wallet
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
        
        guard let aionNetwork = PocketAion.shared?.defaultNetwork else {
            self.error = DownloadTransactionCountOperationError.responseParsing
            self.finish()
            return
        }
        
        try? aionNetwork.eth.estimateGas(from: self.playerAddress, to: monsterToken.address, gas: nil, gasPrice: AppConfiguration.nrgPrice, value: nil, data: submitChaseCallData, blockTag: nil) { (error, estimate) in
            
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
