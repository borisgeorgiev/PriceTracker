//
//  FeedRowView.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//


import SwiftUI

struct FeedRowView: View {
    private let data: PriceData
    
    @State private var priceColor: Color = .primary
    
    init(data: PriceData) {
        self.data = data
    }
    
    private var price: String {
        if data.price.isNaN {
            return "-.--"
        }
        return data.price.formatted(.number.precision(.fractionLength(2)))
    }

    var body: some View {
        HStack {
            Text(data.symbol)
                .font(.headline)

            Spacer()

            Text(price)
                .font(.body)
                .monospacedDigit()
                .foregroundStyle(priceColor)
            
            directionIndicator
        }
        .padding(.vertical, 8)
        .onChange(of: data, { oldValue, newValue in
            let color: Color
            switch data.changeDirection {
            case .up:
                color = .green
            case .down:
                color = .red
            case .none:
                color = .primary
            }
            self.priceColor = color
            
            withAnimation(.easeIn(duration: 1)) {
                priceColor = .primary
            }
        })
    }
    
    @ViewBuilder
    private var directionIndicator: some View {
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
    
}
