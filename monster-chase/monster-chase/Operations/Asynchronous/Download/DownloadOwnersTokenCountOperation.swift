//
//  DownloadOwnersTokenCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadOwnersTokenCountOperationError: Error {
    case totalOwnerTokenParsing
}

public class DownloadOwnersTokenCountOperation: AsynchronousOperation {
    
    public var leaderboardRecord: LeaderboardRecord?
    public var ownerIndex: Int
    public var monsterTokenAddress: String
    
    public init(monsterTokenAddress: String, ownerIndex:Int) {
        self.monsterTokenAddress = monsterTokenAddress
        self.ownerIndex = ownerIndex
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\": true,\"inputs\": [{\"name\": \"_ownerIndex\",\"type\": \"uint256\"}],\"name\": \"getOwnerTokenCountByIndex\",\"outputs\": [{\"name\": \"\",\"type\": \"address\"},{\"name\": \"\",\"type\": \"uint256\"}],\"payable\": false,\"stateMutability\": \"view\",\"type\": \"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadChaseOperationError.chaseParsing
            self.finish()
            return
        }
        
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: monsterTokenAddress, subnetwork: AppConfiguration.subnetwork)
            
            let functionParams = [ownerIndex] as [AnyObject]

            try aionContract.executeConstantFunction(functionName: "getQuest", fromAdress: nil, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in

                if error != nil {
                    self.error = error
                    self.finish()
                    return
                }
                guard let returnValues = result?.first as? [JSON] else {
                    self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                    self.finish()
                    return
                }
                guard let totalHexString = returnValues[1].string else {
                    self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                    self.finish()
                    return
                }
                guard let totalHexStringParsed = HexStringUtil.removeLeadingZeroX(hex: totalHexString) else{
                    self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                    self.finish()
                    return
                }
                
                guard let tokenCount = BigInt.init(totalHexStringParsed, radix: 16) else {
                    self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                    self.finish()
                    return
                }
                guard let wallet = returnValues.first?.string else {
                    self.error = DownloadOwnersTokenCountOperationError.totalOwnerTokenParsing
                    self.finish()
                    return
                }
                
                self.leaderboardRecord = LeaderboardRecord()
                self.leaderboardRecord?.wallet = wallet
                self.leaderboardRecord?.tokenTotal = tokenCount
                
                ///TODO: Set the count
                self.finish()
            })
            
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }

    }
    
}
