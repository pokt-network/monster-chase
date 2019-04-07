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
    public static let devID = "DEVID1"
    public static let monsterTokenAddress = "0xa01F1A6268C9B3636Ac82D907b5F80b9eA7Bb7D3DB85e49858AB612cC4670Cb9"
    public static let network = "AION"
    public static let netID = "32"
    public static let nrgPrice = BigUInt.init(10000000000)
    public static let godfatherPK = "0x2b5d6fd899ccc148b5f85b4ea20961678c04d70055b09dac7857ea430757e6badb4cfe129e670e2fef1b632ed0eab9572954feebbea9cb32134b284763acd34e"
    public static let godfatherAddress = "0xa05b88ac239f20ba0a4d2f0edac8c44293e9b36fa937fb55bf7a1cd61a60f036"
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
