//
//  LeaderboardRecord.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 2/4/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import UIKit
import BigInt

public struct LeaderboardRecord {
    var address: String
    var tokenTotal: BigInt
    
    init(address: String, tokenTotal: BigInt) {
        self.address = address
        self.tokenTotal = tokenTotal
    }
    
}
