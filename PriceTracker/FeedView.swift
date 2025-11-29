//
//  FeedView.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI

struct FeedView: View {
    
    @ObservedObject private var viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List(viewModel.updates) { update in
            NavigationLink(value: update) {
                FeedRowView(data: update)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Prices")
        .navigationDestination(for: PriceData.self) { update in
            // TODO: Add Details view
            EmptyView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                (viewModel.connectionState == .connected ? Color.green : Color.red)
                    .frame(width: 26, height: 26)
                    .mask(Circle())
                    .padding(.horizontal, 8)
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.toggleService()
                } label: {
                    Label(viewModel.isRunning ? "Stop" : "Start",
                          systemImage: viewModel.isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 8)
            }
        }
    }
    
}
