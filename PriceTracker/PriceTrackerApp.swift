//
//  PriceTrackerApp.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI

@main
struct PriceTrackerApp: App {
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                FeedView(viewModel: FeedViewModel(service: EchoPriceService()))
            }
        }
    }
    
}
