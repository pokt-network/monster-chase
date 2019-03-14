//
//  LeaderBoardTableViewCell.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit

class LeaderBoardTableViewCell: UITableViewCell {
    var record: LeaderboardRecord?
    var index: Int?
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var monsterNumberLabel: UILabel!
    @IBOutlet weak var aionAddressLabel: MonsterLabel!
    
    var walletString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell() {
        
        // Styling
        aionAddressLabel.layer.cornerRadius = 7
        aionAddressLabel.layer.borderWidth = 1
        aionAddressLabel.layer.borderColor = AppColors.base.cgColor()
        
        // Updat UI with record data
        let suffix = record?.tokenTotal == 1 ? " Monster":" Monsters";
        self.positionLabel.text = "\(String((index ?? 0) + 1))."
        self.aionAddressLabel.text = record?.address
        self.monsterNumberLabel.text = record?.tokenTotal != nil ? String((record?.tokenTotal)!) + suffix : ""
    }
    
}
