//
//  PocketAionUtils.swift
//  monster-chase
//
//  Created by Luis De Leon on 4/7/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import PocketSwift

public extension PocketAion {
    
    static var shared: PocketAion? = {
        do {
            return try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 10, requestTimeOut: 0)
        } catch {
            return nil
        }
    }()
}

