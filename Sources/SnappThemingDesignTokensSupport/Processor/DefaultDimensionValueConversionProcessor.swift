//
//  DefaultDimensionValueConversionProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming

extension TokenProcessor where Self == DimensionValueConversionProcessor {
    /// A default processor for converting dimension values within a design token hierarchy.
    ///
    /// This processor utilizes a default conversion logic and targets a default unit, ensuring consistency
    /// when handling dimension tokens without requiring custom configuration.
    public static var defaultDesignTokensDimensionValueConversionProcessor: Self {
        .dimensionValueConversion(
            using: .default,
            targetUnit: .default
        )
    }
}
