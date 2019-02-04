//
//  DownloadAndUpdateChaseIsWinnerOperation.swift
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

public enum DownloadAndUpdateChaseIsWinnerOperationError: Error {
    case resultParsing
    case updating
}

public class DownloadAndUpdateChaseIsWinnerOperation: AsynchronousOperation {
    
    private var tavernAddress: String
    private var tokenAddress: String
    private var chaseIndex: BigInt
    private var alledgedWinner: String
    
    public init(tavernAddress: String, tokenAddress: String, chaseIndex: BigInt, alledgedWinner: String) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.chaseIndex = chaseIndex
        self.alledgedWinner = alledgedWinner
        super.init()
    }
    
    open override func main() {
        // Init PocketAion instance
        let pocketAion = PocketAion.init()
        
        let functionABI = "{\"constant\":true,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_questIndex\",\"type\":\"uint256\"},{\"name\":\"_allegedWinner\",\"type\":\"address\"}],\"name\":\"isWinner\",\"outputs\":[{\"name\":\"\",\"type\":\"bool\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}"
        
        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
            self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
            self.finish()
            return
        }
        
        do {
            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: tavernAddress, subnetwork: AppConfiguration.subnetwork)
            
            let functionParams = [tokenAddress, chaseIndex, alledgedWinner] as [Any]
            
            try aionContract.executeConstantFunction(functionName: "isWinner", fromAdress: nil, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in
                
                let hexResult = result?.first as? String
                guard let isWinnerBool = Bool.init(hexResult ?? "false") else{
                    self.error = DownloadAndUpdateChaseIsWinnerOperationError.resultParsing
                    self.finish()
                    return
                }
                
                do {
                    let context = CoreDataUtils.backgroundPersistentContext
                    guard let chase = Chase.getchaseByIndex(chaseIndex: String.init(self.chaseIndex), context: context) else {
                        self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                        self.finish()
                        return
                    }
                    
                    if isWinnerBool {
                        let monster = try Monster.init(obj: chase, context: context)
                        try monster.save()
                    }
                    
                    chase.winner = isWinnerBool
                    try chase.save()
                } catch {
                    self.error = DownloadAndUpdateChaseIsWinnerOperationError.updating
                    self.finish()
                    return
                }
                
            })
            
        } catch {
            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
            self.finish()
        }
        
    }
}
