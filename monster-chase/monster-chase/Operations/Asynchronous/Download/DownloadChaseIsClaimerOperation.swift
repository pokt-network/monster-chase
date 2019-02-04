//
//  DownloadChaseIsClaimerOperation.swift
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

public enum DownloadChaseIsClaimerOperationError: Error {
    case resultParsing
}

public class DownloadChaseIsClaimerOperation: AsynchronousOperation {
    
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseIndex: Int64
    public var alledgedClaimer: String
    public var isClaimer: Bool?
    
    public init(tavernAddress: String, tokenAddress: String, chaseIndex: Int64, alledgedClaimer: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.chaseIndex = chaseIndex
        self.alledgedClaimer = alledgedClaimer
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_allegedClaimer\",\"type\":\"address\"}],\"name\":\"isClaimer\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadChaseOperationError.chaseParsing
            self.finish()
            return
        }
        
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: tavernAddress, subnetwork: AppConfiguration.subnetwork)
            
            let functionParams = [tokenAddress, chaseIndex, alledgedClaimer] as [AnyObject]
            
            try aionContract.executeConstantFunction(functionName: "isClaimer", fromAdress: alledgedClaimer, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in
                
                guard let isClaimberBool = Bool.init(result?.first as? String ?? "")   else {
                    self.error = DownloadChaseOperationError.chaseParsing
                    self.finish()
                    return
                }
                
                self.isClaimer = isClaimberBool

                self.finish()
            })
            
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }
        
    }
}
