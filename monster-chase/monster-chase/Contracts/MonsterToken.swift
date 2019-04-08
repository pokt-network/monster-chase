//
//  MonsterToken.swift
//  monster-chase
//
//  Created by Luis De Leon on 2/10/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift
import SwiftyJSON
import BigInt

public enum MonsterTokenError: Error {
    case initializationError
}

public class MonsterToken {
    
    let aionContract: AionContract
    var address: String {
        get {
            return AppConfiguration.monsterTokenAddress
        }
    }
    
    public init() throws {
        //let pocketAion = PocketAion.init()
        guard let abiInterface = JSONUtils.getStringFromJSONFile(fileName: "MonsterToken") else {
            throw MonsterTokenError.initializationError
        }
        
        guard let aionNetwork = PocketAion.shared()?.defaultNetwork else {
            throw MonsterTokenError.initializationError
        }
        
        aionContract = try AionContract.init(aionNetwork: aionNetwork, address: AppConfiguration.monsterTokenAddress, abiDefinition: abiInterface)
    }
    
    public func getOwnersCount(handler: @escaping AnyArrayCallback) {
        let params: [Any] = []
        try? aionContract.executeConstantFunction(functionName: "getOwnersCount", functionParams: params, fromAddress: nil, gas: nil, gasPrice: nil, value: nil, blockTag: nil, callback: handler)
    }
    
    public func getOwnerTokenCountByIndex(ownerIndex: BigInt, handler: @escaping AnyArrayCallback) {
        let params: [Any] = [ownerIndex]
        try? aionContract.executeConstantFunction(functionName: "getOwnerTokenCountByIndex", functionParams: params, fromAddress: nil, gas: nil, gasPrice: nil, value: nil, blockTag: nil, callback: handler)
    }
    
    public func submitChaseCallData(player: String, name: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String) -> String? {
        let params: [Any] = [player, name, hint, maxWinners, metadata, merkleRoot, merkleBody]
        return try? aionContract.encodeFunctionCall(functionName: "submitChase", functionParams: params)
    }
    
    public func submitProofCallData(player: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool]) -> String? {
        let params: [Any] = [player, chaseIndex, proof, answer, leftOrRight]
        return try? aionContract.encodeFunctionCall(functionName: "submitProof", functionParams: params)
    }
    
    public func submitChase(wallet: Wallet, transactionCount: BigUInt, nrg: BigUInt, player: String, name: String, hint: String, maxWinners: BigInt, metadata: String, merkleRoot: String, merkleBody: String, handler: @escaping StringCallback) {
        let params: [Any] = [player, name, hint, maxWinners, metadata, merkleRoot, merkleBody]
        try? aionContract.executeFunction(functionName: "submitChase", wallet: wallet, functionParams: params, nonce: transactionCount, gas: nrg, gasPrice: AppConfiguration.nrgPrice, value: nil, callback: handler)
    }
    
    public func submitProof(wallet: Wallet, transactionCount: BigUInt, nrg: BigUInt, player: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool], handler: @escaping StringCallback) {
        let params: [Any] = [player, chaseIndex, proof, answer, leftOrRight]
        try? aionContract.executeFunction(functionName: "submitProof", wallet: wallet, functionParams: params, nonce: transactionCount, gas: nrg, gasPrice: AppConfiguration.nrgPrice, value: nil, callback: handler)
    }
    
    public func getChaseAmount(handler: @escaping AnyArrayCallback) {
        let params: [Any] = []
        try? aionContract.executeConstantFunction(functionName: "getChaseAmount", functionParams: params, fromAddress: nil, gas: nil, gasPrice: nil, value: nil, blockTag: nil, callback: handler)
    }
    
    public func isWinner(chaseIndex: BigInt, address: String, handler: @escaping AnyArrayCallback) {
        let params: [Any] = [chaseIndex, address]
        try? aionContract.executeConstantFunction(functionName: "isWinner", functionParams: params, fromAddress: nil, gas: nil, gasPrice: nil, value: nil, blockTag: nil, callback: handler)
    }
    
    public func getChaseHeader(chaseIndex: BigInt, handler: @escaping AnyArrayCallback) {
        try? getChase(functionName: "getChaseHeader", chaseIndex: chaseIndex, handler: handler)
    }
    
    public func getChaseDetail(chaseIndex: BigInt, handler: @escaping AnyArrayCallback) {
        try? getChase(functionName: "getChaseDetail", chaseIndex: chaseIndex, handler: handler)
    }
    
    private func getChase(functionName: String, chaseIndex: BigInt, handler: @escaping AnyArrayCallback) throws {
        let params: [Any] = [chaseIndex]
        try? aionContract.executeConstantFunction(functionName: functionName, functionParams: params, fromAddress: nil, gas: nil, gasPrice: nil, value: nil, blockTag: nil, callback: handler)
    }
}

