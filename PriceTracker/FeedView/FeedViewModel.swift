//
//  FeedViewModel.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation
import Combine

@MainActor
final class FeedViewModel: ObservableObject {

    @Published private(set) var data: [PriceData] = []
    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var isRunning: Bool = false

    let priceService: PriceService
    private var cancellables = Set<AnyCancellable>()
    
    init(service: PriceService) {
        self.priceService = service
        priceService.pricePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                self.updateWithData(update)
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
    
    private func updateWithData(_ priceData: PriceData) {
        if let index = data.firstIndex(where: { $0.symbol == priceData.symbol }) {
            data.remove(at: index)
        }
        
        let insertIndex = data.firstIndex(where: { $0.price < priceData.price }) ?? data.endIndex
        data.insert(priceData, at: insertIndex)
        
        print("Instruments: \(data.count)")
    }
}
