//
//  DownloadAionUsdPriceOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum DownloadAionUsdPriceOperationError: Error {
    case invalidEndpoint
    case invalidResponse
}

public class DownloadAionUsdPriceOperation: AsynchronousOperation {
    
    public var usdPrice: Double?
    public var lastUpdated: Date?
    private let priceApiURL = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=AION&tsyms=USD")
    
    open override func main() {
        
//        guard let urlEndpoint = priceApiURL else {
//            self.error = DownloadAionUsdPriceOperationError.invalidEndpoint
//            self.finish()
//            return
//        }
//
//        let task = URLSession.shared.dataTask(with: urlEndpoint) {(data, response, error) in
//            if error != nil {
//                self.error = error
//                self.finish()
//                return
//            }
//            guard let data = data else {
//                self.error = DownloadAionUsdPriceOperationError.invalidResponse
//                self.finish()
//                return
//            }
//
//            do {
//                let aionTicker = try JSON.init(data: data, options: JSONSerialization.ReadingOptions.allowFragments)
//
//                guard let price = aionTicker.first?.1.double else {
//                    self.error = DownloadAionUsdPriceOperationError.invalidResponse
//                    self.finish()
//                    return
//                }
//
//                self.usdPrice = price
//                self.finish()
//
//            } catch {
//                self.error = error
//                self.finish()
//            }
//        }
//        task.resume()
        self.usdPrice = 1.0
        self.finish()
    }
}
