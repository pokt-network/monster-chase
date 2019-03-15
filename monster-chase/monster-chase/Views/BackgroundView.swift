//
//  BackgroundView.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/25/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class BackgroundView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let contentView = UIView.init(frame: CGRect.init(x: 15, y: 20, width: self.bounds.width - 30, height: self.bounds.height - 30))
        // Add to subview
        addSubview(contentView)
        // Styling
        //contentView.center = self.center
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.borderWidth = 5
        contentView.layer.borderColor = AppColors.base.cgColor()
        contentView.layer.cornerRadius = contentView.frame.height * 0.05
        
        // Remove user interaction
        contentView.isUserInteractionEnabled = false
    }

}
