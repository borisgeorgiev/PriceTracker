//
//  SymbolDetailsViewModel.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation
import Combine

@MainActor
final class SymbolDetailsViewModel: ObservableObject {
    
    @Published private(set) var data: PriceData
    
    private let service: PriceService
    private var cancellables = Set<AnyCancellable>()
    
    var price: String {
        data.price.formatted(.number.precision(.fractionLength(2)))
    }
    
    init(data: PriceData, service: PriceService) {
        self.data = data
        self.service = service
        
        service.pricePublisher
            .filter { [weak self] update in
                update.symbol == self?.data.symbol
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] update in
                guard let self else { return }
                self.data = update
            }
            .store(in: &cancellables)
    }
    
}
