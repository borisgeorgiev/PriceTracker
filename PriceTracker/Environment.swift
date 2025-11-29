//
//  Environment.swift
//  PriceTracker
//
//  Created by Boris Georgiev on 29.11.25.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var priceService: PriceService = EchoPriceService()
}
