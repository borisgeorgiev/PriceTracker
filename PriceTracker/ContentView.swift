//
//  ContentView.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI
import Combine

extension EnvironmentValues {
    @Entry var priceService: PriceService = EchoPriceService()
}

struct ContentView: View {
    
    @Environment(\.priceService) private var priceService
    
    var body: some View {
        NavigationStack {
            FeedView(viewModel: FeedViewModel(service: priceService))
        }
    }
}

#Preview {
    ContentView()
}
