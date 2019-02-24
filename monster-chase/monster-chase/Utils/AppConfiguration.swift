//
//  AppConfiguration.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import BigInt

public struct AppConfiguration {
    
    // TODO: Update tavern and token address
//    public static let tavernAddress = "0xa08ff069FE530B46D31e49FaA38f14f8cC7c60cA3253191B6e6c963769A63303"
//    public static let monsterTokenAddress = "0xA012D37f406Fa8E87F4e2fDf4610dA2473f4f7d14FD4b95952355759F075F027"
//    public static let subnetwork = "32"
    //public static let tavernAddress = "0xa076B80802d5B13b6e03896551a287Ad2f2DEd04d0d4E655fe05c90d8972d42C"
    public static let monsterTokenAddress = "0xa05C38A66D1e28D4E95F8ec90999216deC481f04ef5ABF384aA56d174df0AcA6"
    public static let subnetwork = "0"
    public static let nrgPrice = BigInt.init(10000000000)
    private static let displayedOnboardingKey = "displayedOnboarding"
    
    public static func clearUserDefaults() {
        guard let domain = Bundle.main.bundleIdentifier else {
            return
        }
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
    }
    
    public static func displayedOnboarding() -> Bool {
        return UserDefaults.standard.bool(forKey: displayedOnboardingKey)
    }
    
    public static func setDisplayedOnboarding(displayedOnboarding: Bool) {
        UserDefaults.standard.set(displayedOnboarding, forKey: displayedOnboardingKey)
    }
    
}
