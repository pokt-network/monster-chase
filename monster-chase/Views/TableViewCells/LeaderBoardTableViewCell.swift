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
    var viewController: UIViewController?
    
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var monsterNumberLabel: UILabel!
    @IBOutlet weak var aionAddressLabel: MonsterLabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    
    var walletString = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configureCell(viewController: UIViewController) {
        
        self.viewController = viewController
        
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
    
    @IBAction func copyAddressTapped(sender: AnyObject) {
        guard let viewController = self.viewController else {
            return
        }
        
        let showError = {
            let alertView = viewController.monsterAlertView(title: "Error:", message: "Address field is empty, please try again later")
            viewController.present(alertView, animated: false, completion: nil)
        }
        guard let address = self.aionAddressLabel.text else {
            showError()
            return
        }
        let alertView = viewController.monsterAlertView(title: "Success:", message: "Address copied to your clipboard: " + address)
        UIPasteboard.general.string = address
        viewController.present(alertView, animated: false, completion: nil)
    }
    
}
