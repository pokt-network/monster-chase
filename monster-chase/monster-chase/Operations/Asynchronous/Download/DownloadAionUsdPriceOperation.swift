//
//  DownloadAionUsdPriceOperation.swift
//  monster-chase
//
//  Created by Pabel Nunez Landestoy on 1/28/19.
//  Copyright © 2019 Pocket Network. All rights reserved.
//

import Foundation

public enum DownloadAionUsdPriceOperationError: Error {
    case invalidEndpoint
    case invalidResponse
}

struct CMCEthereumTickerQuote: Decodable {
    let price: Double?
    
    private enum CodingKeys: String, CodingKey {
        case price
    }
}

struct CMCEthereumTickerQuotes: Decodable {
    let usd: CMCEthereumTickerQuote?
    
    private enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

struct CMCEthereumTickerData: Decodable {
    let quotes: CMCEthereumTickerQuotes?
    
    private enum CodingKeys: String, CodingKey {
        case quotes
    }
}

struct CMCEthereumTicker: Decodable {
    let data: CMCEthereumTickerData?
    
    private enum CodingKeys: String, CodingKey {
        case data
    }
}

public class DownloadAionUsdPriceOperation: AsynchronousOperation {
    
    public var usdPrice: Double?
    public var lastUpdated: Date?
    private let priceApiURL = URL(string: "https://api.coinmarketcap.com/v2/ticker/1027")
    
    open override func main() {
        
        guard let urlEndpoint = priceApiURL else {
            self.error = DownloadAionUsdPriceOperationError.invalidEndpoint
            self.finish()
            return
        }
        
        let task = URLSession.shared.dataTask(with: urlEndpoint) {(data, response, error) in
            if error != nil {
                self.error = error
                self.finish()
                return
            }
            guard let data = data else {
                self.error = DownloadAionUsdPriceOperationError.invalidResponse
                self.finish()
                return
            }
            
            do {
                let ethereumTicker = try JSONDecoder().decode(CMCEthereumTicker.self, from: data)
                self.usdPrice = ethereumTicker.data?.quotes?.usd?.price
                self.finish()
                //self.lastUpdated = ethereumTicker.lastUpdated
            } catch {
                self.error = error
                self.finish()
            }
        }
        task.resume()
    }
}
