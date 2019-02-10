//
//  AppConfiguration.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public struct AppConfiguration {
    
    // TODO: Update tavern and token address
    public static let tavernAddress = "0xa0b638D34b31AF19521b5a9A8235d888E492C827970eaD71DE0712520b32dA03"
    public static let monsterTokenAddress = "0xA012D37f406Fa8E87F4e2fDf4610dA2473f4f7d14FD4b95952355759F075F027"
    public static let chainID = 4
    public static let subnetwork = "32"
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
