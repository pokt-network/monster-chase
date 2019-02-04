//
//  UploadChaseOperation.swift
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

public enum UploadChaseOperationError: Error {
    case invalidTxHash
}

public class UploadChaseOperation: AsynchronousOperation {
    
    public var txHash: String?
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseName: String
    public var hint: String
    public var maxWinners: BigInt
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var wallet: Wallet
    public var transactionCount: BigInt
    public var aionPrizeWei: BigInt
    
    public init(wallet: Wallet, tavernAddress: String, tokenAddress: String, chaseName: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String, transactionCount: BigInt, ethPrizeWei: BigInt) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.chaseName = chaseName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.wallet = wallet
        self.transactionCount = transactionCount
        self.aionPrizeWei = ethPrizeWei
        super.init()
    }
    
    open override func main() {
        
        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_maxWinners\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_merkleBody\",\"type\":\"string\"},{\"name\":\"_metadata\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"
        
        var functionParameters = [AnyObject]()
        functionParameters.append(tokenAddress as AnyObject)
        functionParameters.append(chaseName.description as AnyObject)
        functionParameters.append(hint.description as AnyObject)
        functionParameters.append(maxWinners as AnyObject)
        functionParameters.append(merkleRoot as AnyObject)
        functionParameters.append(merkleBody as AnyObject)
        functionParameters.append(metadata as AnyObject)
        
        let data = "['data': [abi:\(functionABI), params: \(functionParameters)]]"
        
        do {
            try PocketAion.eth.sendTransaction(wallet: wallet, nonce: transactionCount, to: tavernAddress, data: data, value: aionPrizeWei, nrgPrice: BigInt.init(1000000000), nrg: BigInt.init(2000000)) { (result, error) in
                
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
