//
//  PriceService.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//


import Foundation
import Combine

enum ConnectionState: Equatable {
    case connected
    case disconnected
}

protocol PriceService {
    
    var pricePublisher: AnyPublisher<PriceData, Never> { get }
    var connectionState: AnyPublisher<ConnectionState, Never> { get }
    
    func start()
    func stop()
    
}
