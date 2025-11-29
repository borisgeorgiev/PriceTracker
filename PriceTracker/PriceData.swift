//
//  PriceData.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//


import Foundation

struct PriceData: Identifiable, Hashable, Sendable {
    enum Change {
        case up, down, none
    }
    
    let symbol: String
    let price: Double
    let previousPrice: Double
    
    var id: String { symbol }

    var changeDirection: Change {
        if price > previousPrice { return .up }
        if price < previousPrice { return .down }
        return .none
    }
}
