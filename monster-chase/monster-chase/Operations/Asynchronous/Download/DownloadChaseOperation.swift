//
//  DownloadChaseOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import BigInt
import SwiftyJSON

public enum DownloadChaseOperationError: Error {
    case chaseParsing
}

public class DownloadChaseOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseIndex: BigInt
    public var chaseDict: [AnyHashable: Any]?
    public var playerAddress: String
    
    public init(tavernAddress: String, tokenAddress: String, chaseIndex: BigInt, playerAddress: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.chaseIndex = chaseIndex
        self.playerAddress = playerAddress
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"}],\"name\":\"getQuest\",\"outputs\":[{\"name\":\"\",\"type\":\"address\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bytes32\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"string\"},{\"name\":\"\",\"type\":\"bool\"},{\"name\":\"\",\"type\":\"uint256\"},{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadChaseOperationError.chaseParsing
            self.finish()
            return
        }
        
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: tavernAddress, subnetwork: AppConfiguration.subnetwork)
            
            let functionParams = [tokenAddress, chaseIndex] as [AnyObject]
            
            try aionContract.executeConstantFunction(functionName: "getQuest", fromAdress: playerAddress, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in
                
                guard let chaseArray = result?.first as? [JSON] else {
                    self.error = DownloadChaseOperationError.chaseParsing
                    self.finish()
                    return
                }
                
                let creator = chaseArray[0].string ?? ""
                let index = chaseArray[1].string ?? "0"
                let name = chaseArray[2].string ?? ""
                let hint = chaseArray[3].string ?? ""
                let merkleRoot = chaseArray[4].string ?? ""
                let merkleBody = chaseArray[5].string ?? ""
                let maxWinners = chaseArray[6].string ?? "0"
                let metadata = chaseArray[7].string ?? ""
                let valid = chaseArray[8].bool ?? false
                let winnersAmount = chaseArray[9].string ?? "0"
                let claimersAmount = chaseArray[10].string ?? "0"
                
                self.chaseDict = [
                    "creator": creator,
                    "index": index,
                    "name": name,
                    "hint": hint,
                    "merkleRoot": merkleRoot,
                    "merkleBody": merkleBody,
                    "maxWinners": maxWinners,
                    "metadata": metadata,
                    "valid": valid,
                    "winnersAmount": winnersAmount,
                    "claimersAmount": claimersAmount
                    ] as [AnyHashable: Any]
                self.finish()
            })
            
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }

    }
    
}
