//
//  EchoPriceService.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import Foundation
import Combine

@MainActor
final class EchoPriceService: PriceService {

    private let priceSubject = PassthroughSubject<PriceData, Never>()
    var pricePublisher: AnyPublisher<PriceData, Never> {
        priceSubject.eraseToAnyPublisher()
    }

    private let connectionStateSubject = CurrentValueSubject<ConnectionState, Never>(.disconnected)
    var connectionState: AnyPublisher<ConnectionState, Never> {
        connectionStateSubject.eraseToAnyPublisher()
    }

    private var webSocket: URLSessionWebSocketTask?
    private let session: URLSession

    private var currentSymbols: Set<String> = []
    
    private var running: Bool = false
    
    // loopback prices
    private var timerCancellable: AnyCancellable?
    private var latestPrices: [String: Double] = [:]

    init(session: URLSession = .shared) {
        self.session = session
    }

    func start() {
        connectWebSocket()
        running = true
        
        send(.subscribe(symbols: Array(currentSymbols)))
        
        startPriceLoop()
    }

    func stop() {
        send(.unsubscribe(symbols: Array(currentSymbols).map { $0.uppercased() }))
        running = false
        
        webSocket?.cancel(with: .normalClosure, reason: nil)
        connectionStateSubject.send(.disconnected)
    }
    
    func subscribe(for symbols: [String]) {
        currentSymbols.formUnion(symbols.map { $0.uppercased() })
        send(.subscribe(symbols: Array(currentSymbols)))
    }

    func unsubscribe(for symbols: [String]) {
        currentSymbols.subtract(symbols.map { $0.uppercased() })
        send(.unsubscribe(symbols: symbols.map { $0.uppercased() }))
    }

    private func connectWebSocket() {
        guard webSocket == nil else { return }

        let url = URL(string: "wss://ws.postman-echo.com/raw")!
        let task = session.webSocketTask(with: url)
        webSocket = task

        task.resume()
        connectionStateSubject.send(.connected)

        receive()
    }

    private func receive() {
        webSocket?.receive { [weak self] result in
            guard let self else { return }
            Task { @MainActor in
                switch result {
                case .success(let message):
                    self.handle(message)
                case .failure:
                    self.connectionStateSubject.send(.disconnected)
                    self.webSocket = nil
                }

                self.receive() // next
            }
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        if case .string(let text) = message,
           let data = text.data(using: .utf8),
           let message = try? JSONDecoder().decode(SocketMessage.self, from: data) {
            switch message {
            case .subscribe(let symbols):
                print("subscribe for: \(symbols)")
            case .unsubscribe(let symbols):
                print("unsubscribe for: \(symbols)")
            case .price(let data):
                priceSubject.send(data)
            }
        }
    }
    
    // MARK: Loopback

    private func startPriceLoop() {
        timerCancellable = Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard self?.running == true else {
                    return
                }
                self?.generateAndSendAllPrices()
            }
    }

    private func generateAndSendAllPrices() {
        for symbol in currentSymbols {
            let previous = latestPrices[symbol] ?? Double.random(in: 80...300)
            let newPrice = previous + Double.random(in: -3...3)

            let data = PriceData(symbol: symbol,
                                 price: newPrice,
                                 previousPrice: previous)

            latestPrices[symbol] = newPrice
            send(.price(data))
        }
    }

    private func send(_ message: SocketMessage) {
        guard let webSocket else { return }
        
        do {
            let data = try JSONEncoder().encode(message)
            if let string = String(data: data, encoding: .utf8) {
                webSocket.send(.string(string)) { [weak self] error in
                    if let error {
                        DispatchQueue.main.async {
                            self?.handleError(error)
                        }
                    }
                }
            }
        } catch {
            // handle encoding failure if needed
        }
    }
    
    private func handleError(_ error: Error) {
        // TODO: error
    }
}

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
