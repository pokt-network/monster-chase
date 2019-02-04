//
//  MonsterCollectionViewCell.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/1/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import SwiftHEXColors
import MapKit
import BigInt

class MonsterCollectionViewCell: UICollectionViewCell {
    // Variables
    var monster: Monster?
    
    // IBOutlet
    @IBOutlet weak var chaseNameLabel: UILabel?
    @IBOutlet weak var chaseBackgroundView: UIImageView?
    @IBOutlet weak var chaseStampImage: UIImageView?
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let monsterBackgroundView = self.chaseBackgroundView {
            monsterBackgroundView.layer.cornerRadius = monsterBackgroundView.frame.size.width / 2
            monsterBackgroundView.clipsToBounds = true
        }
    }
    
    func configureCellFor(index: Int, playerLocation: CLLocation?) {
        
        guard let monster = self.monster else {
            self.configureEmptyCellFor(index: index)
            return
        }
        
        if let questNameLabel = self.chaseNameLabel {
            questNameLabel.text = monster.name.uppercased()
        }
        
        if let bananoBackgroundView = self.chaseBackgroundView {
            let bananoColor = UIColor(hexString: monster.hexColor )
            bananoBackgroundView.backgroundColor = bananoColor
        }
    }
    
    func configureEmptyCellFor(index: Int) {
        if let bananoQuestImage = self.chaseStampImage {
            bananoQuestImage.image = #imageLiteral(resourceName: "NO-BANANO")
        }
        
        if index > 0 {
            if let questNameLabel = self.chaseNameLabel {
                questNameLabel.text = ""
            }
            
            return
        }
        
        if let questNameLabel = self.chaseNameLabel {
            questNameLabel.text = "NO BANANOS YET"
        }
        
    }
    
}
