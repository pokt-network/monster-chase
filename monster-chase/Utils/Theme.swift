//
//  Theme.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/24/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import UIKit

enum AppColors {
    case base
    case accent
    case neutral
    
    func uiColor() -> UIColor {
        switch self {
        case .base:
            return UIColor.init(red: (77/255), green: (75/255), blue: (159/255), alpha: 1)
        case .accent:
            return UIColor.init(red: (14/255), green: (168/255), blue: (158/255), alpha: 1)
        case .neutral:
            return UIColor.init(red: (242/255), green: (157/255), blue: (43/255), alpha: 1)
        }
    }
    
    func cgColor() -> CGColor {
        switch self {
        case .base:
            return UIColor.init(red: (77/255), green: (75/255), blue: (159/255), alpha: 1).cgColor
        case .accent:
            return UIColor.init(red: (14/255), green: (168/255), blue: (158/255), alpha: 1).cgColor
        case .neutral:
            return UIColor.init(red: (242/255), green: (157/255), blue: (43/255), alpha: 1).cgColor
        }
    }
}
