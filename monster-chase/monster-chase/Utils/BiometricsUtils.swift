//
//  BiometricsUtils.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import SwiftKeychainWrapper
import BiometricAuthentication
import PocketSwift

public typealias BiometricsSetupSuccessHandler = () -> Void
public typealias BiometricsErrorHandler = (Error) -> Void
public typealias BiometricsAuthSuccessHandler = (Wallet) -> Void

public enum BiometricsUtilsError: Error {
    case biometricsUnavailable
    case playerNotFound
    case cancelledByUser
    case unknownError
    case passcodeAuthError
    case setupError
    case credentialsRetrievalError
}

public struct BiometricsUtils {
    
    public static let biometricsAvailable = BioMetricAuthenticator.canAuthenticate()
    private static let keychainKey = "MonsterBiometricAuthPassphrase"
    
    public static func removeBiometricRecord(playerAddress: String) -> Bool {
        let recordKey = self.keychainKey + playerAddress
        return KeychainWrapper.standard.remove(key: recordKey)
    }
    
    // Returns wheter or not a biometric record exists for the current player
    public static func biometricRecordExists(playerAddress: String) -> Bool {
        let recordKey = self.keychainKey + playerAddress
        guard let _ = KeychainWrapper.standard.string(forKey: recordKey, withAccessibility: .always) else {
            return false
        }
        return true
    }
    
    // Retrieves existing passphrase from keychain upon succesful biometric auth
    public static func retrieveWalletWithBiometricAuth(successHandler: @escaping BiometricsAuthSuccessHandler, errorHandler: @escaping BiometricsErrorHandler) {
        // Check if biometrics are available
        guard biometricsAvailable else {
            errorHandler(BiometricsUtilsError.biometricsUnavailable)
            return
        }
        
        // Fetch the current player
        var playerInstance: Player?
        do {
            playerInstance = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("\(error)")
            errorHandler(BiometricsUtilsError.unknownError)
        }
        
        guard let player = playerInstance else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        guard let playerAddress = player.address else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        let keychainKey = self.keychainKey + playerAddress
        if !self.biometricRecordExists(playerAddress: playerAddress) {
            errorHandler(BiometricsUtilsError.credentialsRetrievalError)
            return
        }
        
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Biometric Authentication", fallbackTitle: "Biometric Authentication", success: {
            guard let passphrase = KeychainWrapper.standard.string(forKey: keychainKey, withAccessibility: .always) else {
                errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                return
            }
            do {
                guard let wallet = try player.getWallet(passphrase: passphrase) else {
                    errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                    return
                }
                
                // Call the success handler with the retrieved wallet
                successHandler(wallet)
            } catch {
                errorHandler(BiometricsUtilsError.credentialsRetrievalError)
            }
        }) { (error) in
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                errorHandler(BiometricsUtilsError.cancelledByUser)
            } else if error == .biometryNotAvailable || error == .fallback || error == .biometryNotEnrolled {
                errorHandler(BiometricsUtilsError.biometricsUnavailable)
            } else if error == .biometryLockedout {
                // show passcode authentication
                BioMetricAuthenticator.authenticateWithPasscode(reason: "Biometrics Auth Locked, please provide Passcode", success: {
                    // Return wallet on success
                    guard let passphrase = KeychainWrapper.standard.string(forKey: keychainKey, withAccessibility: .always) else {
                        errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                        return
                    }
                    do {
                        guard let wallet = try player.getWallet(passphrase: passphrase) else {
                            errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                            return
                        }
                        
                        // Call the success handler with the retrieved wallet
                        successHandler(wallet)
                    } catch {
                        errorHandler(BiometricsUtilsError.credentialsRetrievalError)
                    }
                }) { (error) in
                    print(error.message())
                    errorHandler(BiometricsUtilsError.passcodeAuthError)
                }
            } else {
                errorHandler(BiometricsUtilsError.unknownError)
                print("\(error)")
            }
        }
    }
    
    // Needs for a player to exist in the local database
    public static func setupPlayerBiometricRecord(passphrase: String, successHandler: @escaping BiometricsSetupSuccessHandler, errorHandler: @escaping BiometricsErrorHandler) {
        
        // Check if biometrics are available
        guard biometricsAvailable else {
            errorHandler(BiometricsUtilsError.biometricsUnavailable)
            return
        }
        
        // Fetch the current player
        var playerInstance: Player?
        do {
            playerInstance = try Player.getPlayer(context: CoreDataUtils.mainPersistentContext)
        } catch {
            print("\(error)")
            errorHandler(BiometricsUtilsError.unknownError)
        }
        
        guard let player = playerInstance else {
            errorHandler(BiometricsUtilsError.playerNotFound)
            return
        }
        
        // Attempt bio auth
        BioMetricAuthenticator.authenticateWithBioMetrics(reason: "Biometric Authentication Setup", fallbackTitle: "Biometric Authentication", success: {
            // Save passphrase to keychain with correct accesibility
            do {
                try savePassphraseToKeychain(passphrase: passphrase, player: player)
                successHandler()
            } catch {
                print("\(error)")
                errorHandler(error)
            }
        }, failure: { (error) in
            // do nothing on canceled
            if error == .canceledByUser || error == .canceledBySystem {
                errorHandler(BiometricsUtilsError.cancelledByUser)
            } else if error == .biometryNotAvailable || error == .fallback || error == .biometryNotEnrolled {
                errorHandler(BiometricsUtilsError.biometricsUnavailable)
            } else if error == .biometryLockedout {
                // show passcode authentication
                BioMetricAuthenticator.authenticateWithPasscode(reason: "Biometrics Auth Locked, please provide Passcode", success: {
                    // Save passphrase
                    do {
                        try savePassphraseToKeychain(passphrase: passphrase, player: player)
                        successHandler()
                    } catch {
                        print("\(error)")
                        errorHandler(error)
                    }
                }) { (error) in
                    print(error.message())
                    errorHandler(BiometricsUtilsError.passcodeAuthError)
                }
            } else {
                errorHandler(BiometricsUtilsError.unknownError)
                print("\(error)")
            }
        })
    }
    
    private static func savePassphraseToKeychain(passphrase: String, player: Player) throws {
        guard let playerAddress = player.address else {
            throw BiometricsUtilsError.setupError
        }
        let recordKey = self.keychainKey + playerAddress
        let success = KeychainWrapper.standard.set(passphrase, forKey: recordKey, withAccessibility: .always)
        if !success {
            throw BiometricsUtilsError.setupError
        }
    }
}
