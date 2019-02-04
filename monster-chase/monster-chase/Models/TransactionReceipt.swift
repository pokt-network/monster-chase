//
//  TransactionReceipt.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/30/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import Pocket

public enum TransactionStatus {
    case success
    case failure
}

public struct TransactionReceipt {
    
    public var rawReceipt: [String: JSON]
    // Parsed properties of the rawReceipt
    public var status: TransactionStatus {
        get {
            if let rawStatus = rawReceipt["status"]?.value() as? String {
                switch rawStatus {
                case "0x0":
                    return .failure
                case "0x1":
                    return .success
                default:
                    return .failure
                }
            } else {
                return .failure
            }
        }
    }
    
    public init(rawReceipt: [String: JSON]) {
        self.rawReceipt = rawReceipt
    }
    
}
