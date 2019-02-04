//
//  DownloadChaseAmountOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketAion
import enum Pocket.PocketPluginError
import SwiftyJSON
import BigInt

public enum DownloadChaseAmountOperationError: Error {
    case amountParsing
}

public class DownloadChaseAmountOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseAmount: BigInt?
    
    public init(tavernAddress: String, tokenAddress: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"}],\"name\":\"getQuestAmount\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadChaseAmountOperationError.amountParsing
            self.finish()
            return
        }
        
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: tavernAddress, subnetwork: AppConfiguration.subnetwork)
            
            var functionParams = [Any]()
            functionParams.append(tokenAddress)
            
            try aionContract.executeConstantFunction(functionName: "getQuestAmount", fromAdress: nil, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in

                let hexResult = result?.first as? String
                guard let hexResultBigInt = BigInt.init(HexStringUtil.removeLeadingZeroX(hex: hexResult ?? "0") ?? "0", radix: 16) else{
                    self.error = DownloadChaseAmountOperationError.amountParsing
                    self.finish()
                    return
                }
                
                self.chaseAmount = hexResultBigInt
                self.finish()
                
            })
                
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }
        
    }
    
}

