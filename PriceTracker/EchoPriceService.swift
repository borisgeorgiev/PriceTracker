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

    private var symbols: [String]

    init(symbols: [String], session: URLSession = .shared) {
        self.session = session
        self.symbols = symbols
    }

    func start() {
        connectWebSocket()
    }

    func stop() {
        webSocket?.cancel(with: .normalClosure, reason: nil)
        connectionStateSubject.send(.disconnected)
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
           let update = try? JSONDecoder().decode(PriceData.self, from: data) {
            priceSubject.send(update)
        }
    }
    
}
