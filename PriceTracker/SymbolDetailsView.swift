//
//  SymbolDetailsView.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI

struct SymbolDetailsView: View {
    @StateObject private var viewModel: SymbolDetailsViewModel

    init(data: PriceData, service: PriceService) {
        _viewModel = StateObject(wrappedValue: SymbolDetailsViewModel(data: data, service: service))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                priceSection
                
                chartSection

                descriptionSection
            }
            .padding()
        }
        .navigationTitle(viewModel.data.symbol)
        .navigationBarTitleDisplayMode(.large)
    }

    private var priceSection: some View {
        HStack(spacing: 8) {
            
            Text(viewModel.price)
                .font(.largeTitle.weight(.semibold))
                .monospacedDigit()
            
            directionArrow
                .font(.title.weight(.medium))
        }
        .padding()
        .frame(maxWidth: .infinity)
    }
    
    private var chartSection: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(.thinMaterial)
            .frame(height: 200)
            .overlay {
                Text("Chart placeholder")
                    .font(.callout)
            }
    }

    private var directionArrow: some View {
        switch viewModel.data.changeDirection {
        case .up:
            Image(systemName: "arrow.up")
                .foregroundStyle(Color.green)
        case .down:
            Image(systemName: "arrow.down")
                .foregroundStyle(Color.red)
        default:
            Image(systemName: "circle")
                .foregroundStyle(Color.primary)
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("About \(viewModel.data.symbol)")
                .font(.title2)
                .fontWeight(.semibold)

            Text("""
This is a placeholder description for \(viewModel.data.symbol).  
In a real production app this could include:

• Company overview  
• Market sector  
• Business summary  
• Recent performance highlights  
• CEO and leadership  
• Key metrics (market cap, P/E ratio, etc.)
• News
""")
            .font(.body)
            .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
