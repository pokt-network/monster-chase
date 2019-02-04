//
//  DownloadOwnersCountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/2/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadOwnersCountOperationError: Error {
    case totalOwnerParsing
}

public class DownloadOwnersCountOperation: AsynchronousOperation {
    
    var total: BigInt?
    public var monsterTokenAddress: String
    
    
    public init(monsterTokenAddress: String) {
        self.monsterTokenAddress = monsterTokenAddress
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\":true,\"inputs\":[],\"name\":\"getOwnersCount\",\"outputs\":[{\"name\": \"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadChaseOperationError.chaseParsing
            self.finish()
            return
        }
    
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: monsterTokenAddress, subnetwork: AppConfiguration.subnetwork)
            
            let functionParams = [] as [AnyObject]
            
            try aionContract.executeConstantFunction(functionName: "getOwnersCount", fromAdress: nil, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in
                
                if error != nil {
                    self.error = error
                    self.finish()
                    return
                }
                
                guard let totalHexString = result?.first as? String else {
                    self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                    self.finish()
                    return
                }
                
                guard let totalHexStringParsed = HexStringUtil.removeLeadingZeroX(hex: totalHexString) else{
                    self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                    self.finish()
                    return
                }
                
                guard let totalAmount = BigInt.init(totalHexStringParsed, radix: 16) else {
                    self.error = DownloadOwnersCountOperationError.totalOwnerParsing
                    self.finish()
                    return
                }
                
                self.total = totalAmount
                self.finish()
                
                self.finish()
            })
            
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }

    }
    
}
