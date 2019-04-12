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
            return try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 10, requestTimeOut: 999999999)
        } catch {
            return nil
        }
    }()
    
//    static func shared() -> PocketAion? {
//        do {
//            return try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 5, requestTimeOut: 999999999)
//        } catch {
//            return nil
//        }
//    }
    
//    static var shared: PocketAion? = {
//        do {
//            return try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 5, requestTimeOut: 999999999)
//        } catch {
//            return nil
//        }
//    }()
    
//    private static var sharedInstance: PocketAion?
//
//    static var shared: PocketAion? {
//        get {
//            do {
//                if let result = PocketAion.sharedInstance {
//                    return result
//                } else {
//                    PocketAion.sharedInstance = try PocketAion.init(devID: AppConfiguration.devID, netIds: [AppConfiguration.netID], defaultNetID: AppConfiguration.netID, maxNodes: 5, requestTimeOut: 999999999)
//                    return PocketAion.sharedInstance
//                }
//            } catch {
//                return nil
//            }
//        }
//    }
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
