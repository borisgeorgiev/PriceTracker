//
//  SocketMessage.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation

enum SocketMessage: Codable {
    case subscribe(symbols: [String])
    case unsubscribe(symbols: [String])
    case price(PriceData)

    private enum CodingKeys: String, CodingKey {
        case type
        case symbols
        case payload
    }

    private enum MessageType: String, Codable {
        case subscribe
        case unsubscribe
        case price
    }

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
        case .price:
            let price = try container.decode(PriceData.self, forKey: .payload)
            self = .price(price)
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
        case .price(let price):
            try c.encode(MessageType.price, forKey: .type)
            try c.encode(price, forKey: .payload)
        }
    }
}
