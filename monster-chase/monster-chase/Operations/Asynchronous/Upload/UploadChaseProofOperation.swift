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
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseIndex: BigInt
    public var proof: [String]
    public var answer: String
    public var wallet: Wallet
    public var transactionCount: BigInt
    
    public init(wallet: Wallet, transactionCount: BigInt, tavernAddress: String, tokenAddress: String, chaseIndex: BigInt, proof: [String], answer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.wallet = wallet
        self.transactionCount = transactionCount
        self.chaseIndex = chaseIndex
        self.proof = proof
        self.answer = answer
        super.init()
    }
    
    open override func main() {
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_proof\",\"type\":\"bytes32[]\"},{\"name\":\"_answer\",\"type\":\"bytes32\"}],\"name\":\"submitProof\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"}"
        
        var functionParameters = [AnyObject]()
        functionParameters.append(tokenAddress as AnyObject)
        functionParameters.append(chaseIndex as AnyObject)
        functionParameters.append(proof as AnyObject)
        functionParameters.append(answer as AnyObject)
        
        let data = "['data': [abi:\(functionABI), params: \(functionParameters)]]"
        
        do {
            try PocketAion.eth.sendTransaction(wallet: wallet, nonce: transactionCount, to: tavernAddress, data: data, value: BigInt.init(), nrgPrice: BigInt.init(1000000000), nrg: BigInt.init(6000000)) { (result, error) in
                
                if error != nil {
                    self.error = error
                    self.finish()
                    return
                }
                
                guard let txHash = result?.first else {
                    self.error = UploadChaseOperationError.invalidTxHash
                    self.finish()
                    return
                }
                
                self.txHash = txHash
                self.finish()
            }
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to send transaction with the provided values.")
            self.finish()
        }

    }
}

