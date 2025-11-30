//
//  PriceTrackerTests.swift
//  PriceTrackerTests
//
//  Created by Boris Georgiev on 29.11.25.
//

import Testing
@testable import PriceTracker
import Foundation
import Combine

struct PriceTrackerTests {
    
    @Test
    func feedViewModel_reflectsConnectionState_onStartAndStop() async throws {
        let service = EchoPriceService()
        let feedVM = await FeedViewModel(service: service)
        
        #expect(await feedVM.connectionState == .disconnected)
        
        await service.start()
        
        var cancellable: AnyCancellable?
        let publisher = await feedVM.$connectionState
        let observedConnected: ConnectionState? = await withCheckedContinuation { continuation in
            cancellable = publisher
                .timeout(1, scheduler: DispatchQueue.global())
                .sink(receiveCompletion: { _ in
                    continuation.resume(returning: nil)
                }, receiveValue: { value in
                    if value == .connected {
                        continuation.resume(returning: value)
                    }
                })
        }
        
        if cancellable != nil {
            cancellable = nil
        }
        
        #expect(observedConnected == .connected, "Expected FeedViewModel.connectionState to become .connected after start()")

        await service.stop()
        
        let observedDisconnected: ConnectionState? = await withCheckedContinuation { continuation in
            cancellable = publisher
                .timeout(1, scheduler: DispatchQueue.global())
                .sink(receiveCompletion: { _ in
                    continuation.resume(returning: nil)
                }, receiveValue: { value in
                    if value == .disconnected {
                        continuation.resume(returning: value)
                    }
                })
        }
        
        if cancellable != nil {
            cancellable = nil
        }
        
        #expect(observedDisconnected == .disconnected, "Expected FeedViewModel.connectionState to become .disconnected after stop()")
    }

    @Test
    func feedViewModel_receivesSinglePriceUpdate() async throws {
        let service = EchoPriceService()
        let feedVM = await FeedViewModel(service: service)
        
        await service.start()
        
        let symbol = "ZZZZ"
        let price = 123.45
        let previous = 100.0
        let payload = PriceData(symbol: symbol, price: price, previousPrice: previous)

        await service.send(.prices([payload]))

        var cancellable: AnyCancellable?
        let publisher = await feedVM.$data
        let observed: PriceData? = await withCheckedContinuation { continuation in
            cancellable = publisher
                .timeout(1, scheduler: DispatchQueue.global())
                .sink(receiveCompletion: { completion in
                    continuation.resume(returning: nil)
                }, receiveValue: { data in
                    if let priceData = data.first(where: { $0.symbol == symbol }) {
                        continuation.resume(returning: priceData)
                    }
                })
        }
        
        if cancellable != nil {
            cancellable = nil
        }
        
        // verify update is received
        let result = try #require(observed, "Expected to receive echoed price for \(symbol)")
        #expect(result.symbol == symbol)
        #expect(result.price == price)
        #expect(result.previousPrice == previous)
        #expect(result.changeDirection == .up)
    }
    
    @Test
    func feedViewModel_receivesMultiplePriceUpdates() async throws {
        let service = EchoPriceService()
        let feedVM = await FeedViewModel(service: service)

        await service.start()

        let payloads: [PriceData] = [
            PriceData(symbol: "MULTI1", price: 201.0, previousPrice: 200.0),
            PriceData(symbol: "MULTI2", price: 150.5, previousPrice: 149.0),
            PriceData(symbol: "MULTI3", price: 75.25, previousPrice: 70.0)
        ]
        
        await service.send(.prices(payloads))

        let wantedSymbols = Set(payloads.map { $0.symbol })

        var observedSet = Set<PriceData>()

        var cancellable: AnyCancellable?
        let publisher = await feedVM.$data
        _ = await withCheckedContinuation { continuation in
            cancellable = publisher
                .timeout(1, scheduler: DispatchQueue.global())
                .sink(receiveCompletion: { completion in
                    continuation.resume(returning: ())
                }, receiveValue: { data in
                    observedSet.formUnion(data.filter { wantedSymbols.contains($0.symbol) })
                    if Set(observedSet.map { $0.symbol }) == wantedSymbols {
                        continuation.resume(returning: ())
                    }
                })
        }
        
        if cancellable != nil {
            cancellable = nil
        }

        #expect(Set(observedSet.map { $0.symbol }) == wantedSymbols, "Expected to receive echoed prices for all symbols: \(wantedSymbols)")

        // verify all items are received
        for expected in payloads {
            let item = try #require(observedSet.first(where: { $0 == expected }), "Missing item for \(expected.symbol)")
            #expect(item.symbol == expected.symbol)
            #expect(item.price == expected.price)
            #expect(item.previousPrice == expected.previousPrice)
        }
    }

    @Test
    func symbolDetailsViewModel_updatesOnEchoedPrice() async throws {
        let service = EchoPriceService()

        let symbol = "YYYY"
        let initial = PriceData(symbol: symbol, price: 10.0, previousPrice: 10.0)
        let detailsVM = await SymbolDetailsViewModel(data: initial, service: service)

        await service.start()

        let updated = PriceData(symbol: symbol, price: 20.0, previousPrice: 10.0)
        await service.send(.prices([updated]))
        
        var cancellable: AnyCancellable?
        let publisher = await detailsVM.$data
        let observed: PriceData? = await withCheckedContinuation { continuation in
            cancellable = publisher
                .timeout(1, scheduler: DispatchQueue.global())
                .sink(receiveCompletion: { completion in
                    continuation.resume(returning: nil)
                }, receiveValue: { priceData in
                    if priceData == updated {
                        continuation.resume(returning: priceData)
                    }
                })
        }
        
        if cancellable != nil {
            cancellable = nil
        }

        #expect(observed?.symbol == symbol)
        #expect(observed?.price == updated.price)
        #expect(observed?.previousPrice == updated.previousPrice)
        #expect(observed?.changeDirection == .up)

        // validate price formatting
        let formatted = await detailsVM.price
        let separator = Locale.current.decimalSeparator ?? "."
        #expect(formatted == "20\(separator)00")
    }

}
