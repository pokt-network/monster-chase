//
//  AionUtils.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/29/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import CoreData
import BigInt

public struct AionUtils {
    
    public static let unitaryAionToWeiQuotient = 1000000000000000000
    
    public static func convertUSDAmountToAion(usdAmount: Double) -> Double {
        return usdAmount / unitaryAionPriceUSD()
    }
    
    public static func convertEthAmountToUSD(aionAmount: Double) -> Double {
        return aionAmount * unitaryAionPriceUSD()
    }
    
    // Converts wei amount to usd amount
    public static func convertWeiToUSD(wei: BigInt) -> Double {
        return AionUtils.convertWeiToAion(wei: wei) * AionUtils.unitaryAionPriceUSD()
    }
    
    // Converts wei to aion amount
    public static func convertWeiToAion(wei: BigInt) -> Double {
        return Double.init(wei)/Double(AionUtils.unitaryAionToWeiQuotient)
    }
    
    // Returns the price of a single aion in usd amount
    public static func unitaryAionPriceUSD() -> Double {
        var result = 0.0
        var player: Player?
        do {
            player = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            return result
        }
        
        guard let playerInstance = player else {
            return result
        }
        result = playerInstance.aionUsdPrice
        
        // refresh data if 0
        if result == 0.0 {
            guard let playerAddress = playerInstance.address else {
                return result
            }
            AppInitQueueDispatcher.init(playerAddress: playerAddress, tavernAddress: AppConfiguration.tavernAddress, monsterTokenAddress: AppConfiguration.tavernAddress).initDispatchSequence(completionHandler: nil)
        }
        
        return result
    }
    
    public static func convertEthToWei(aion: Double) -> BigInt {
        return BigInt.init(aion * Double(AionUtils.unitaryAionToWeiQuotient))
    }
    
}
