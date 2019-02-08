//
//  UILabel+extension.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class MonsterLabel: UILabel {
    
    override func drawText(in rect: CGRect) {
        let insets: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 10.0, bottom: 0.0, right: 10.0)
        
        super.drawText(in: rect.inset(by: insets))
    }
    
}
