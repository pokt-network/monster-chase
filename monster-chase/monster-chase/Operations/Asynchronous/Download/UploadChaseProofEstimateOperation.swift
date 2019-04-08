//
//  UploadChaseProofEstimateOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

import SwiftyJSON
import BigInt

public enum UploadChaseProofEstimateOperationError: Error {
    case resultParsing
    case monsterTokenInitError
}

public class UploadChaseProofEstimateOperation: AsynchronousOperation {
    
    public var estimatedGas: BigInt?
    public var tokenAddress: String
    public var chaseIndex: BigInt
    public var proof: [String]
    public var answer: String
    public var playerAddress: String
    public var leftOrRight: [Bool]
    
    public init(playerAddress: String, tokenAddress: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool]) {
        self.tokenAddress = tokenAddress
        self.playerAddress = playerAddress
        self.chaseIndex = chaseIndex
        self.proof = proof
        self.answer = answer
        self.leftOrRight = leftOrRight
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = UploadChaseProofEstimateOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        guard let submitProofCallData = monsterToken.submitProofCallData(player: self.playerAddress, chaseIndex: self.chaseIndex, proof: self.proof, answer: self.answer, leftOrRight: self.leftOrRight) else {
            self.error = UploadChaseProofEstimateOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        guard let aionNetwork = PocketAion.shared()?.defaultNetwork else {
            self.error = UploadChaseProofEstimateOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        aionNetwork.eth.estimateGas(from: self.playerAddress, to: monsterToken.address, gas: nil, gasPrice: AppConfiguration.nrgPrice, value: nil, data: submitProofCallData, blockTag: nil) { (error, estimate) in
            
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            if let estimate = estimate {
                self.estimatedGas = estimate
                self.finish()
            } else {
                self.error = UploadChaseProofEstimateOperationError.resultParsing
                self.finish()
                return
            }
        }
    }
}

