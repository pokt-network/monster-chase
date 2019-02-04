//
//  UIColor+extension.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

extension UIColor {
    static func random() -> UIColor {
        return UIColor(red:   .random(),
                       green: .random(),
                       blue:  .random(),
                       alpha: 1.0)
    }
}
