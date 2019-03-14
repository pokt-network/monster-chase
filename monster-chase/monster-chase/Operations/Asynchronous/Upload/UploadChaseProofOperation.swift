//
//  UploadChaseProofOperation.swift
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

public enum UploadChaseProofOperationError: Error {
    case invalidTxHash
}

public class UploadChaseProofOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var playerAddress: String
    public var chaseIndex: BigInt
    public var proof: [String]
    public var answer: String
    public var leftOrRight: [Bool]
    public var wallet: Wallet
    public var transactionCount: BigInt
    public var nrg: BigInt
    
    public init(wallet: Wallet, transactionCount: BigInt, playerAddress: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool], nrg: BigInt) {
        self.wallet = wallet
        self.transactionCount = transactionCount
        self.playerAddress = playerAddress
        self.chaseIndex = chaseIndex
        self.proof = proof
        self.answer = answer
        self.leftOrRight = leftOrRight
        self.nrg = nrg
        super.init()
    }
    
    open override func main() {
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = UploadChaseOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        monsterToken.submitProof(wallet: self.wallet, transactionCount: self.transactionCount, nrg: self.nrg, player: self.playerAddress, chaseIndex: self.chaseIndex, proof: self.proof, answer: self.answer, leftOrRight: self.leftOrRight) { (txHashArray, error) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let txHash = txHashArray?.first else {
                self.error = UploadChaseOperationError.invalidTxHash
                self.finish()
                return
            }
            
            self.txHash = txHash
            self.finish()
        }
    }
}

