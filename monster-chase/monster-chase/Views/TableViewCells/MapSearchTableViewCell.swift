//
//  MapSearchTableViewCell.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/6/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import MapKit

class MapSearchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    var place : MKMapItem?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell() {
        titleLabel.text = place?.name
        subtitleLabel.text = place?.placemark.title
    }
    
    func configureEmptyCell() {
        titleLabel.text = ""
        subtitleLabel.text = ""
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
