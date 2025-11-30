//
//  PriceService.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//


import Foundation
import Combine

@globalActor actor PriceServiceActor {
    static let shared = PriceServiceActor()
}

enum ConnectionState: Equatable {
    case connected
    case disconnected
}

@PriceServiceActor
protocol PriceService {
    
    nonisolated var pricePublisher: AnyPublisher<[PriceData], Never> { get }
    nonisolated var connectionState: AnyPublisher<ConnectionState, Never> { get }
    
    func start()
    func stop()
    
    func subscribe(for symbols: [String])
    func unsubscribe(for symbols: [String])
    
}
