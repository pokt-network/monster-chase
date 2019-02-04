//
//  UploadChaseEstimateOperation.swift
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

public enum UploadChaseEstimateOperationError: Error {
    case resultParsing
}

public class UploadChaseEstimateOperation: AsynchronousOperation {
    
    public var estimatedGasWei: BigInt?
    public var tavernAddress: String
    public var tokenAddress: String
    public var chaseName: String
    public var hint: String
    public var maxWinners: BigInt
    public var merkleRoot: String
    public var merkleBody: String
    public var metadata: String
    public var ethPrizeWei: BigInt
    public var playerAddress: String
    
    public init(playerAddress: String, tavernAddress: String, tokenAddress: String, chaseName: String, hint: String, maxWinners: BigInt, merkleRoot: String, merkleBody: String, metadata: String, ethPrizeWei: BigInt) {
        self.tavernAddress = tavernAddress
        self.tokenAddress = tokenAddress
        self.chaseName = chaseName
        self.hint = hint
        self.maxWinners = maxWinners
        self.merkleRoot = merkleRoot
        self.merkleBody = merkleBody
        self.metadata = metadata
        self.ethPrizeWei = ethPrizeWei
        self.playerAddress = playerAddress
        super.init()
    }
    
    open override func main() {
        // TODO: Implement estimate gas after plugin update
        // Init PocketAion instance
//        let pocketAion = PocketAion.init()
//
//        let functionABI = "{\"constant\":false,\"inputs\":[{\"name\":\"_tokenAddress\",\"type\":\"address\"},{\"name\":\"_name\",\"type\":\"string\"},{\"name\":\"_hint\",\"type\":\"string\"},{\"name\":\"_maxWinners\",\"type\":\"uint256\"},{\"name\":\"_merkleRoot\",\"type\":\"bytes32\"},{\"name\":\"_merkleBody\",\"type\":\"string\"},{\"name\":\"_metadata\",\"type\":\"string\"}],\"name\":\"createQuest\",\"outputs\":[],\"payable\":true,\"stateMutability\":\"payable\",\"type\":\"function\"}"
//
//        guard let jsonArray = JSON.init(parseJSON: functionABI).array else {
//            self.error = DownloadChaseAmountOperationError.amountParsing
//            self.finish()
//            return
//        }
//
//        do {
//            let aionContract = try AionContract.init(pocketAion: pocketAion, abiDefinition: jsonArray, contractAddress: tavernAddress, subnetwork: AppConfiguration.subnetwork)
//
//            var functionParams = [tokenAddress, chaseName, hint, maxWinners, merkleRoot, merkleBody, metadata] as [AnyObject]
//
//            try aionContract.executeConstantFunction(functionName: "createQuest", fromAdress: playerAddress, functionParams: functionParams, nrg: BigInt.init(50000), nrgPrice: BigInt.init(20000000000), value: nil, handler: { (result, error) in
//
//                let hexResult = result?.first as? String
//                guard let hexResultBigInt = BigInt.init(HexStringUtil.removeLeadingZeroX(hex: hexResult ?? "0") ?? "0", radix: 16) else{
//                    self.error = DownloadChaseAmountOperationError.amountParsing
//                    self.finish()
//                    return
//                }
//
//                self.chaseAmount = hexResultBigInt
//                self.finish()
//
//            })
//
//        } catch {
//            self.error = PocketPluginError.Aion.executionError("Failed to initialize AionContract instance with the provided values.")
//            self.finish()
//        }
//
//        let txParams = [
//            "from": playerAddress,
//            "to": tavernAddress,
//            "data": "0x" + data
//            ] as [AnyHashable: Any]
//
//        let params = [
//            "rpcMethod": "eth_estimateGas",
//            "rpcParams": [txParams]
//            ] as [AnyHashable: Any]
//
//        guard let query = try? PocketEth.createQuery(subnetwork: AppConfiguration.subnetwork, params: params, decoder: nil) else {
//            self.error = PocketPluginError.queryCreationError("Query creation error")
//            self.finish()
//            return
//        }
//
//        Pocket.shared.executeQuery(query: query) { (queryResponse, error) in
//            if error != nil {
//                self.error = error
//                self.finish()
//                return
//            }
//
//            guard let estimatedGasHex = (queryResponse?.result?.value() as? String)?.replacingOccurrences(of: "0x", with: "") else {
//                self.error = UploadQuestEstimateOperationError.resultParsing
//                self.finish()
//                return
//            }
//
//            guard let estimatedGas = BigInt.init(estimatedGasHex, radix: 16) else {
//                self.error = UploadQuestEstimateOperationError.resultParsing
//                self.finish()
//                return
//            }
//
//            self.estimatedGasWei = estimatedGas * BigInt.init(1000000000)
//            self.finish()
//        }
    }
}
