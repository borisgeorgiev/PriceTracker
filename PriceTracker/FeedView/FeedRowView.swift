//
//  FeedRowView.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//


import SwiftUI

struct FeedRowView: View {
    private let data: PriceData
    
    init(data: PriceData) {
        self.data = data
    }

    var body: some View {
        HStack {
            Text(data.symbol)
                .font(.headline)

            Spacer()

            Text(data.price.formatted(.number.precision(.fractionLength(2))))
                .font(.body)
                .monospacedDigit()

            switch data.changeDirection {
            case .up:
                Image(systemName: "arrow.up")
                    .foregroundStyle(.green)
            case .down:
                Image(systemName: "arrow.down")
                    .foregroundStyle(.red)
            default:
                Image(systemName: "circle")
            }
            
        }
        .padding(.vertical, 8)
    }
}
