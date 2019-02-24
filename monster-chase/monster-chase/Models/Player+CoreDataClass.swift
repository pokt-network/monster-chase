//
//  Player+CoreDataClass.swift
//  
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//
//

import Foundation
import CoreData
import PocketAion
import Pocket

public enum PlayerPersistenceError: Error {
    case retrievalError
    case creationError
    case walletCreationError
}


@objc(Player)
public class Player: NSManagedObject {
    
    private var godfatherWallet: Wallet?
    
    convenience init(obj: [AnyHashable: Any]?, context: NSManagedObjectContext) throws {
        self.init(context: context)
        if let playerObj = obj {
            self.address = playerObj["address"] as? String ?? ""
            self.balanceAmp = playerObj["balanceWei"] as? String ?? "0"
            self.transactionCount = playerObj["transactionCount"] as? String ?? "0"
            self.tavernMonsterAmount = playerObj["tavernMonsterAmount"] as? String ?? "0"
            self.aionUsdPrice = playerObj["aionUsdPrice"] as? Double ?? 0.0
        }
    }
    
    func save() throws {
        try self.managedObjectContext?.save()
    }
    
    // Either returns a new player to save data to, or returns the existing player
    public static func getPlayer(context: NSManagedObjectContext) throws -> Player {
        var result: Player
        let fetchRequest: NSFetchRequest<Player> = Player.fetchRequest()
        let playerStore = try context.fetch(fetchRequest)
        
        if playerStore.count > 0 {
            guard let player = playerStore.first else {
                throw PlayerPersistenceError.retrievalError
            }
            result = player
        } else {
            throw PlayerPersistenceError.retrievalError
        }
        return result
    }
    
    public func getWallet(passphrase: String) throws -> Wallet? {
        var result: Wallet?
        if let playerAddress = self.address {
            result = try Wallet.retrieveWallet(network: "AION", subnetwork: AppConfiguration.subnetwork, address: playerAddress, passphrase: passphrase)
        }
        return result
    }
    
    public static func createPlayer(walletPassphrase: String) throws -> Player {
        // First create the wallet
        //let wallet = try PocketAion.createWallet(subnetwork: AppConfiguration.subnetwork, data: nil)
        let wallet = try PocketAion.importWallet(privateKey: "0xc62667d350e1873632e0e55a4417609c19636754d2e6a3df7d71b9d2d5cce2a1ac44d29b49220ce926756c85c21a4673cf064564a3088fcaf3f661a5eac95271", subnetwork: "0", address: "0xa013ccd08d826dac8069007478376dfd6867f59e7e7f55b54445190911a51b6c", data: nil)
        
        if try wallet.save(passphrase: walletPassphrase) == false {
            throw PlayerPersistenceError.walletCreationError
        }
        
        // Create the player
        let context = CoreDataUtils.mainPersistentContext
        let player = try Player.init(obj: ["address":wallet.address], context: context)
        try player.save()
        return player
    }
    
    public func getGodfatherWallet() throws -> Wallet {
        if let result = self.godfatherWallet {
            return result;
        } else {
            self.godfatherWallet = try PocketAion.importWallet(privateKey: "0xc62667d350e1873632e0e55a4417609c19636754d2e6a3df7d71b9d2d5cce2a1ac44d29b49220ce926756c85c21a4673cf064564a3088fcaf3f661a5eac95271", subnetwork: "0", address: "0xa013ccd08d826dac8069007478376dfd6867f59e7e7f55b54445190911a51b6c", data: nil)
            return self.godfatherWallet!
        }
    }
}
