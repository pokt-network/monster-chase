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
    public static let tavernAddress = "0xa05B88aC239F20ba0A4d2f0eDAc8C44293e9b36Fa937fB55BF7A1cD61a60f036"
    public static let monsterTokenAddress = "0xa0E6dda34358cD8e987069893bBeA87F14E569a12C424986Fe77f327b31c7682"
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
