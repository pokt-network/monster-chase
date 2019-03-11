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
    
    // Localhost
    public static let monsterTokenAddress = "0xa0D7e4eD2CA859E9f2C758A9bEF0ef69C5eD741B6F3F7C6E3F6ed9d9579a3425"
    public static let subnetwork = "0"
    public static let nrgPrice = BigInt.init(10000000000)
    public static let godfatherPK = "0xc62667d350e1873632e0e55a4417609c19636754d2e6a3df7d71b9d2d5cce2a1ac44d29b49220ce926756c85c21a4673cf064564a3088fcaf3f661a5eac95271"
    public static let godfatherAddress = "0xa013ccd08d826dac8069007478376dfd6867f59e7e7f55b54445190911a51b6c"
    private static let displayedOnboardingKey = "displayedOnboarding"
    
    // Mastery
//    public static let monsterTokenAddress = "0xA062262ED2E8d20D5beCa1dc9B494beBeFbb5A0A36e3351EAc8bE3D93eF2BD0c"
//    public static let subnetwork = "32"
//    public static let nrgPrice = BigInt.init(20000000000)
//    public static let godfatherPK = "0x2b5d6fd899ccc148b5f85b4ea20961678c04d70055b09dac7857ea430757e6badb4cfe129e670e2fef1b632ed0eab9572954feebbea9cb32134b284763acd34e"
//    public static let godfatherAddress = "0xa05b88ac239f20ba0a4d2f0edac8c44293e9b36fa937fb55bf7a1cd61a60f036"
//    private static let displayedOnboardingKey = "displayedOnboarding"
    
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
