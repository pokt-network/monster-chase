//
//  DefaultMonsterButton.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/24/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class DefaultMonsterButton: UIButton {
    @IBOutlet var contentView: UIView!
    
    private let DEFAULT_BORDER_WIDTH = CGFloat.init(4)
    private let DEFAULT_CORNER_RADIUS = CGFloat.init(20)
    private let DEFAULT_BUTTON_HEIGHT: CGFloat = 50
    private let DEFAULT_BUTTON_WIDTH: CGFloat = 180
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("DefaultMonsterButton", owner: self, options: nil)
        
        // Orange View
        let orangeView = UIView.init(frame: CGRect.init(x: 10, y: -10, width: self.bounds.width - 12, height: DEFAULT_BUTTON_HEIGHT - 5))
        // Add to subview
        addSubview(orangeView)
        // Styling
        orangeView.layer.cornerRadius = DEFAULT_CORNER_RADIUS
        orangeView.layer.backgroundColor = AppColors.neutral.cgColor()
        
        // Purple borders
        contentView.frame = CGRect.init(x: self.bounds.origin.x, y: self.bounds.origin.y, width: self.bounds.width, height: DEFAULT_BUTTON_HEIGHT)
        // Add to subview
        addSubview(contentView)
        // Styling
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        contentView.layer.borderWidth = DEFAULT_BORDER_WIDTH
        contentView.layer.borderColor = AppColors.base.cgColor()
        contentView.layer.cornerRadius = DEFAULT_CORNER_RADIUS
        contentView.layer.backgroundColor = UIColor.clear.cgColor
        
        // Button Style
        self.setTitleColor(AppColors.base.uiColor(), for: .normal)
        self.titleLabel?.font = UIFont(name: "Verdana-Bold", size: 12)
        self.titleEdgeInsets = UIEdgeInsets.init(top: (DEFAULT_BUTTON_HEIGHT / 2) - 30, left: 0, bottom: 0, right: 0)
        
        // Remove user interaction from added views
        orangeView.isUserInteractionEnabled = false
        contentView.isUserInteractionEnabled = false
    }

}
