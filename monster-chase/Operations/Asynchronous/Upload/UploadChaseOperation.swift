//
//  UploadChaseOperation.swift
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

public enum UploadChaseOperationError: Error {
    case invalidTxHash
    case monsterTokenInitError
    case invalidHeaderReceipt
}

public class UploadChaseOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var playerAddress: String
    public var chaseName: String
    public var hint: String
    public var maxWinners: BigInt
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var wallet: Wallet
    public var nrg: BigInt
    
    public init(wallet: Wallet, playerAddress: String, chaseName: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String, nrg: BigInt) {
        self.playerAddress = playerAddress
        self.chaseName = chaseName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.wallet = wallet
        self.nrg = nrg
        super.init()
    }
    
    open override func main() {
        
        guard let monsterToken = try? MonsterToken.init() else {
            self.error = UploadChaseOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        guard let aionNetwork = PocketAion.shared?.defaultNetwork else {
            self.error = UploadChaseOperationError.monsterTokenInitError
            self.finish()
            return
        }
        
        aionNetwork.eth.getTransactionCount(address: self.wallet.address, blockTag: nil) { (error, transactionCount) in
            if let error = error {
                self.error = error
                self.finish()
                return
            }
            
            guard let transactionCount = transactionCount else {
                self.error = UploadChaseOperationError.invalidHeaderReceipt
                self.finish()
                return
            }
            
            monsterToken.submitChase(wallet: self.wallet, transactionCount: BigUInt.init(transactionCount), nrg: BigUInt.init(2000000), player: self.playerAddress, name: self.chaseName, hint: self.hint, maxWinners: self.maxWinners, metadata: self.metadata, merkleRoot: self.merkleRoot, merkleBody: self.merkleBody) { (txError, txHashOpt) in
                if let txError = txError {
                    self.error = txError
                    self.finish()
                    return
                }
                
                guard let txHash = txHashOpt else {
                    self.error = UploadChaseOperationError.invalidTxHash
                    self.finish()
                    return
                }
                
                self.txHash = txHash
                self.finish()
            }
        }
    }
}
