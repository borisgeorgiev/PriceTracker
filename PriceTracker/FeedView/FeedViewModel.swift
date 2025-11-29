//
//  FeedViewModel.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class FeedViewModel: ObservableObject {

    @Published private(set) var updates: [PriceData] = []
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var isRunning: Bool = false

    let priceService: PriceService
    private var cancellables = Set<AnyCancellable>()
    private var latestBySymbol: [String: PriceData] = [:]

    init(service: PriceService) {
        self.priceService = service
        priceService.pricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                self.latestBySymbol[update.symbol] = update
                self.recomputeRows()
            }
            .store(in: &cancellables)

        priceService.connectionState
            .receive(on: DispatchQueue.main)
            .assign(to: &$connectionState)
        
        priceService.subscribe(for: ["AAPL", "AMZN"])
    }

    func start() {
        isRunning = true
        priceService.start()
    }

    func stop() {
        isRunning = false
        priceService.stop()
    }

    func toggleService() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }

    private func recomputeRows() {
        updates = latestBySymbol.values
            .sorted(by: { $0.price > $1.price })
    }
}
