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
    public var godfatherAddress: String? {
        get {
            if let godfatherWallet = self.getGodfatherWallet() {
                return godfatherWallet.address
            } else {
                return nil
            }
        }
    }
    
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
    
    public static func dropTable(context: NSManagedObjectContext) throws {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Player")
        let request = NSBatchDeleteRequest(fetchRequest: fetch)
        let _ = try context.execute(request)
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
        let wallet = try PocketAion.createWallet(subnetwork: AppConfiguration.subnetwork, data: nil)
        
        if try wallet.save(passphrase: walletPassphrase) == false {
            throw PlayerPersistenceError.walletCreationError
        }
        
        // Create the player
        return try Player.createAndSavePlayer(address: wallet.address)
    }
    
    public static func createPlayer(walletPassphrase: String, privateKey: String) throws -> Player {
        // First create the wallet
        let wallet = try PocketAion.importWallet(privateKey: privateKey, subnetwork: AppConfiguration.subnetwork, address: "0xa05b88ac239f20ba0a4d2f0edac8c44293e9b36fa937fb55bf7a1cd61a60f036", data: nil)
        
        if try wallet.save(passphrase: walletPassphrase) == false {
            throw PlayerPersistenceError.walletCreationError
        }
        
        // Create the player
        return try Player.createAndSavePlayer(address: wallet.address)
    }
    
    private static func createAndSavePlayer(address: String) throws -> Player {
        let context = CoreDataUtils.mainPersistentContext
        let player = try Player.init(obj: ["address": address], context: context)
        try player.save()
        return player
    }
    
    public func getGodfatherWallet() -> Wallet? {
        if let result = self.godfatherWallet {
            return result;
        } else {
            guard let godfatherWallet = try? PocketAion.importWallet(privateKey: AppConfiguration.godfatherPK, subnetwork: AppConfiguration.subnetwork, address: AppConfiguration.godfatherAddress, data: nil) else {
                return nil
            }
            self.godfatherWallet = godfatherWallet
            return self.godfatherWallet
        }
    }
    
    public static func wipePlayerData(context: NSManagedObjectContext, player: Player, wallet: Wallet) throws -> Bool {
        var result = false
        
        guard let playerAddress = player.address else {
            return result
        }
        
        // First delete biometric record
        if BiometricsUtils.biometricRecordExists(playerAddress: playerAddress) {
            let _ = BiometricsUtils.removeBiometricRecord(playerAddress: playerAddress)
        }
        
        // Second delete core data
        try Chase.dropTable(context: context)
        try Monster.dropTable(context: context)
        try Player.dropTable(context: context)
        try Transaction.dropTable(context: context)
        
        // Third delete wallet
        let _ = try wallet.delete()
        
        // Set result to true
        result = true
        
        return result
    }
}
