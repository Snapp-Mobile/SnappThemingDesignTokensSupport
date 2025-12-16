//
//  DefaultDesignTokensFlatteingProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens

extension TokenProcessor where Self == FlattenProcessor {
    /// A default processor for flattening a design token hierarchy while preserving dynamic colors.
    ///
    /// This processor uses ``flattenWithDynamicColors(pathConversionStrategy:dynamicColorKeys:)``
    /// with default parameters to simplify the token structure.
    public static var defaultDesignTokensFlatteingProcessor: FlattenProcessor {
        .flattenWithDynamicColors()
    }

    /// Creates a `FlattenProcessor` configured to flatten a token hierarchy, with special handling for dynamic colors.
    ///
    /// The flattening process stops at the level where dynamic color keys are found, preserving the group structure
    /// necessary for representing light and dark mode colors.
    /// - Parameters:
    ///   - pathConversionStrategy: The strategy for converting token paths into a flat structure. Defaults to `.convertToCamelCase`.
    ///   - dynamicColorKeys: The keys used to identify dynamic color groups (e.g., "light" and "dark"). Defaults to `.default`.
    static func flattenWithDynamicColors(
        pathConversionStrategy: FlattenProcessor.PathConversionStrategy = .convertToCamelCase,
        dynamicColorKeys: DynamicColorKeys = .default
    ) -> Self {
        .flatten(
            pathConversionStrategy: pathConversionStrategy,
            flatteningDepth: .limitWhere { group in
                guard
                    case .value(.color) = group[dynamicColorKeys.light],
                    case .value(.color) = group[dynamicColorKeys.dark]
                else {
                    return false
                }
                return true
            }
        )
    }
}
