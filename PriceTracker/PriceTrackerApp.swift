//
//  PriceTrackerApp.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI

@main
struct PriceTrackerApp: App {
    @StateObject private var feedViewModel = FeedViewModel(service: EchoPriceService())
    @State private(set) var path = NavigationPath()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $path) {
                FeedView(viewModel: feedViewModel)
                    .onOpenURL { url in
                        handleDeepLink(url)
                    }
            }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "stocks",
              url.host == "symbol",
              let symbol = url.pathComponents.dropFirst().first?.uppercased() else {
            return
        }

        if let priceData = feedViewModel.data.first(where: { $0.symbol == symbol }) {
            path = NavigationPath()
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                path.append(priceData)
            }
        }
    }
}
