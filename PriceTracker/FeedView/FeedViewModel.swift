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
        
        let symbols = [
            "AAPL","MSFT","NVDA","TSLA","AMZN","GOOGL","META","NFLX","AMD","INTC","BABA","ORCL","CRM","ADBE","PYPL","JPM","BAC","WMT","KO","PFE","NKE","T","VZ","UBER","LYFT","SHOP","SQ","SPOT","BP","RIO"
          ]
        
        for symbol in symbols {
            let placeholderData = PriceData(symbol: symbol, price: .nan, previousPrice: .nan)
            data.append(placeholderData)
        }
        // ideally these should come from a service, also should have the ability to add/remove (PricesService supports it)
        Task {
            await priceService.subscribe(for: symbols)
        }
    }

    func start() {
        Task { @MainActor in
            await priceService.start()
            isRunning = true
        }
    }

    func stop() {
        Task { @MainActor in
            isRunning = false
            await priceService.stop()
        }
    }

    func toggleService() {
        if isRunning {
            stop()
        } else {
            start()
        }
    }
    
    private func updateWithData(_ pricesData: [PriceData]) {
        var updatedData = data
        for priceData in pricesData {
            if let index = updatedData.firstIndex(where: { $0.symbol == priceData.symbol }) {
                updatedData.remove(at: index)
            }
            
            let insertIndex = updatedData.firstIndex(where: { $0.price < priceData.price }) ?? updatedData.endIndex
            updatedData.insert(priceData, at: insertIndex)
        }
        
        data = updatedData
    }
}

