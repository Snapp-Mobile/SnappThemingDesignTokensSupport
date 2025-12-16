//
//  DefaultDimensionValueConversionProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming

extension TokenProcessor where Self == DimensionValueConversionProcessor {
    public static var defaultDesignTokensDimensionValueConversionProcessor: Self {
        .dimensionValueConversion(
            using: .default,
            targetUnit: .default
        )
    }
}
