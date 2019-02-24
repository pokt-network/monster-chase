//
//  JSONUtils.swift
//  monster-chase
//
//  Created by Luis De Leon on 2/10/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public struct JSONUtils {
    
    public static func getStringFromJSONFile(fileName: String) -> String? {
        var result: String? = nil
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                result = String.init(data: data, encoding: .utf8)
            } catch {
                result = nil
            }
        }
        return result
    }
    
}
