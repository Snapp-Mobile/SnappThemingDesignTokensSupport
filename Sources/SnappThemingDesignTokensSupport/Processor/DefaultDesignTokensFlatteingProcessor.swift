//
//  DefaultDesignTokensFlatteingProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens

extension TokenProcessor where Self == FlattenProcessor {
    public static var defaultDesignTokensFlatteingProcessor: FlattenProcessor {
        .flattenWithDynamicColors()
    }

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
