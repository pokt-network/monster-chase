//
//  UpdatePlayerOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import CoreData
import BigInt

public class UpdatePlayerOperation: SynchronousOperation {
    
    private var balanceWei: BigInt?
    private var transactionCount: BigInt?
    private var questAmount: BigInt?
    private var ethUsdPrice: Double?
    
    public init(balanceWei: BigInt?, transactionCount: BigInt?, questAmount: BigInt?, ethUsdPrice: Double?) {
        self.balanceWei = balanceWei
        self.transactionCount = transactionCount
        self.questAmount = questAmount
        self.ethUsdPrice = ethUsdPrice
        super.init()
    }
    
    open override func main() {
        let context = CoreDataUtils.backgroundPersistentContext
        context.performAndWait {
            do {
                let player = try Player.getPlayer(context: context)
                if let balanceWei = self.balanceWei {
                    player.balanceWei = String.init(balanceWei)
                }
                
                if let transactionCount = self.transactionCount {
                    player.transactionCount = String.init(transactionCount)
                }
                
                if let questAmount = self.questAmount {
                    player.tavernMonsterAmount = String.init(questAmount)
                }
                
                if let ethUsdPrice = self.ethUsdPrice {
                    player.aionUsdPrice = ethUsdPrice
                }
                
                // Save updated player
                try player.save()
            } catch {
                self.error = error
                print("Error performing UpdatePlayerOperation")
            }
        }
    }
}
