//
//  MonsterToken.swift
//  monster-chase
//
//  Created by Luis De Leon on 2/10/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import SwiftyJSON
import BigInt
import Pocket

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
        let pocketAion = PocketAion.init()
        guard let abiInterface = JSONUtils.getStringFromJSONFile(fileName: "MonsterToken") else {
            throw MonsterTokenError.initializationError
        }
        
        guard let jsonArray = JSON.init(parseJSON: abiInterface).array else {
            throw MonsterTokenError.initializationError
        }
        
        aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: AppConfiguration.monsterTokenAddress, subnetwork: AppConfiguration.subnetwork)
    }
    
    public func getOwnersCount(handler: @escaping PocketAionAnyHandler) {
        let params: [Any] = []
        try? aionContract.executeConstantFunction(functionName: "getOwnersCount", fromAdress: nil, functionParams: params, nrg: nil, nrgPrice: nil, value: nil, handler: handler)
    }
    
    public func getOwnerTokenCountByIndex(ownerIndex: BigInt, handler: @escaping PocketAionAnyHandler) {
        let params: [Any] = [ownerIndex]
        try? aionContract.executeConstantFunction(functionName: "getOwnerTokenCountByIndex", fromAdress: nil, functionParams: params, nrg: nil, nrgPrice: nil, value: nil, handler: handler)
    }
    
    public func submitChaseCallData(player: String, name: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String) -> String? {
        let params: [Any] = [player, name, hint, maxWinners, metadata, merkleRoot, merkleBody]
        if let result = try? aionContract.getFunctionCallData(functionName: "submitChase", functionParams: params) {
            return result
        } else {
            return nil
        }
    }
    
    public func submitProofCallData(player: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool]) -> String? {
        let params: [Any] = [player, chaseIndex, proof, answer, leftOrRight]
        if let result = try? aionContract.getFunctionCallData(functionName: "submitProof", functionParams: params) {
            return result
        } else {
            return nil
        }
    }
    
    public func submitChase(wallet: Wallet, transactionCount: BigInt, nrg: BigInt, player: String, name: String, hint: String, maxWinners: BigInt, metadata: String, merkleRoot: String, merkleBody: String, handler: @escaping PocketAionStringHandler) {
        let params: [Any] = [player, name, hint, maxWinners, metadata, merkleRoot, merkleBody]
        try? aionContract.executeFunction(functionName: "submitChase", wallet: wallet, functionParams: params, nonce: transactionCount, nrg: nrg, nrgPrice: AppConfiguration.nrgPrice, value: BigInt.init(0), handler: handler);
    }
    
    public func submitProof(wallet: Wallet, transactionCount: BigInt, nrg: BigInt, player: String, chaseIndex: BigInt, proof: [String], answer: String, leftOrRight: [Bool], handler: @escaping PocketAionStringHandler) {
        let params: [Any] = [player, chaseIndex, proof, answer, leftOrRight]
        try? aionContract.executeFunction(functionName: "submitProof", wallet: wallet, functionParams: params, nonce: transactionCount, nrg: nrg, nrgPrice: AppConfiguration.nrgPrice, value: BigInt.init(0), handler: handler);
    }
    
    public func getChaseAmount(handler: @escaping PocketAionAnyHandler) {
        let params: [Any] = []
        try? aionContract.executeConstantFunction(functionName: "getChaseAmount", fromAdress: nil, functionParams: params, nrg: nil, nrgPrice: nil, value: nil, handler: handler)
    }
    
    public func isWinner(chaseIndex: BigInt, address: String, handler: @escaping PocketAionAnyHandler) {
        let params: [Any] = [chaseIndex, address]
        try? aionContract.executeConstantFunction(functionName: "isWinner", fromAdress: nil, functionParams: params, nrg: nil, nrgPrice: nil, value: nil, handler: handler)
    }
    
    public func getChaseHeader(chaseIndex: BigInt, handler: @escaping PocketAionAnyHandler) {
        try? getChase(functionName: "getChaseHeader", chaseIndex: chaseIndex, handler: handler)
    }
    
    public func getChaseDetail(chaseIndex: BigInt, handler: @escaping PocketAionAnyHandler) {
        try? getChase(functionName: "getChaseDetail", chaseIndex: chaseIndex, handler: handler)
    }
    
    private func getChase(functionName: String, chaseIndex: BigInt, handler: @escaping PocketAionAnyHandler) throws {
        let params: [Any] = [chaseIndex]
        try? aionContract.executeConstantFunction(functionName: functionName, fromAdress: nil, functionParams: params, nrg: nil, nrgPrice: nil, value: nil, handler: handler)
    }
}

