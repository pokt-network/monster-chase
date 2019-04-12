//
//  ChaseCollectionViewCell.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/29/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import SwiftHEXColors
import MapKit
import BigInt

class ChaseCollectionViewCell: UICollectionViewCell {
    // Variables
    var chase: Chase?
    
    // IBOutlet
    @IBOutlet weak var monsterNameLabel: UILabel?
    @IBOutlet weak var monsterCountLabel: UILabel?
    @IBOutlet weak var chaseDistanceLabel: UILabel?
    @IBOutlet weak var monsterBackgroundView: UIImageView?
    @IBOutlet weak var monsterStampImage: UIImageView?
    @IBOutlet weak var hintTextView: UITextView?
    @IBOutlet weak var monsterContainerViewHeightConstraint: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let monsterBackgroundView = self.monsterBackgroundView {
            monsterBackgroundView.layer.cornerRadius = monsterBackgroundView.frame.size.width / 2
            monsterBackgroundView.clipsToBounds = true
        }
    }
    
    func configureCellFor(index: Int, playerLocation: CLLocation?) {
        
        guard let chase = self.chase else {
            self.configureEmptyCellFor(index: index)
            return
        }
        
        if let questNameLabel = self.monsterNameLabel {
            questNameLabel.text = chase.name.uppercased()
        }
        if chase.maxWinners == "0" {
            if let monsterCountLabel = self.monsterCountLabel {
                monsterCountLabel.text = "INFINITE"
                monsterCountLabel.font = monsterCountLabel.font.withSize(14)
            }
        } else {
            if let monsterCountLabel = self.monsterCountLabel {
                monsterCountLabel.text = "\(chase.winnersAmount ?? "0")/\(chase.maxWinners ?? "0")"
                monsterCountLabel.font = monsterCountLabel.font.withSize(17)
            }
        }
        
        if let playerLocation = playerLocation {
            let distanceMeters = LocationUtils.chaseDistanceToPlayerLocation(chase: chase, playerLocation: playerLocation).magnitude
            let roundedDistanceMeters = Double(round(10*distanceMeters)/10)
            var distanceText = "?"
            
            if roundedDistanceMeters > 999 {
                let roundedDistanceKM = roundedDistanceMeters/1000
                if roundedDistanceKM > 999 {
                    distanceText = String.init(format: "%.1fK KM", (roundedDistanceKM/1000))
                } else {
                    distanceText = String.init(format: "%.1f KM", (roundedDistanceKM))
                }
            } else {
                distanceText = String.init(format: "%.1f M", roundedDistanceMeters)
            }
            if let chaseDistanceLabel = self.chaseDistanceLabel {
                chaseDistanceLabel.text = distanceText
            }
        } else {
            if let chaseDistanceLabel = self.chaseDistanceLabel {
                chaseDistanceLabel.text = "?"
            }
        }
        if let hintTextView = self.hintTextView {
            hintTextView.text = chase.hint
            
        }
        
        if let monsterBackgroundView = self.monsterBackgroundView {
            let monsterColor = UIColor(hexString: chase.hexColor)
            monsterBackgroundView.backgroundColor = monsterColor
        }
        
        if UIDevice.modelName == "iPhone SE" || UIDevice.modelName == "Simulator iPhone SE" {
            monsterContainerViewHeightConstraint.constant = 140
        }
    }
    
    func configureEmptyCellFor(index: Int) {
        if index > 0 {
            if let chaseNameLabel = self.monsterNameLabel {
                chaseNameLabel.text = ""
            }
            
            return
        }
        
        if let chaseNameLabel = self.monsterNameLabel {
            chaseNameLabel.text = "NO MONSTERS YET"
        }
        
        if let monsterCountLabel = self.monsterCountLabel {
            monsterCountLabel.text = "N/A"
        }
        
        if let chaseDistanceLabel = self.chaseDistanceLabel {
            chaseDistanceLabel.text = "N/A"
        }
        
        if let hintTextView = self.hintTextView {
            hintTextView.text = "N/A"
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: Any) {
        
    }
}
