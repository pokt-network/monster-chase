//
//  MonsterTextField.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class MonsterTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.layer.cornerRadius = 14
        self.layer.borderColor = AppColors.base.cgColor()
        self.layer.borderWidth = 2
        self.textColor = UIColor.black
    }
    
}
