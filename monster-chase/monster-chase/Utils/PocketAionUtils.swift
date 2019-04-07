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
            return try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 5, requestTimeOut: 999999999)
        } catch {
            return nil
        }
    }()
}

//public struct PocketAionUtils {
//
////    private static var pocketAion: PocketAion
////
////    public static func instance() -> PocketAion{
////        if let result = self.pocketAion {
////            return result
////        } else {
////
////        }
////    }
//}
