//
//  SocketMessage.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation

enum SocketMessage: Sendable {
    case subscribe(symbols: [String])
    case unsubscribe(symbols: [String])
    case prices([PriceData])

    private enum CodingKeys: String, CodingKey {
        case type
        case symbols
        case payload
    }

    private enum MessageType: String, Codable {
        case subscribe
        case unsubscribe
        case prices
    }
    
}

nonisolated extension SocketMessage: Codable {
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(MessageType.self, forKey: .type)
        switch type {
        case .subscribe:
            let symbols = try container.decode([String].self, forKey: .symbols)
            self = .subscribe(symbols: symbols)
        case .unsubscribe:
            let symbols = try container.decode([String].self, forKey: .symbols)
            self = .unsubscribe(symbols: symbols)
        case .prices:
            let prices = try container.decode([PriceData].self, forKey: .payload)
            self = .prices(prices)
        }
    }

    func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .subscribe(let symbols):
            try c.encode(MessageType.subscribe, forKey: .type)
            try c.encode(symbols, forKey: .symbols)
        case .unsubscribe(let symbols):
            try c.encode(MessageType.unsubscribe, forKey: .type)
            try c.encode(symbols, forKey: .symbols)
        case .prices(let prices):
            try c.encode(MessageType.prices, forKey: .type)
            try c.encode(prices, forKey: .payload)
        }
    }
    
}
