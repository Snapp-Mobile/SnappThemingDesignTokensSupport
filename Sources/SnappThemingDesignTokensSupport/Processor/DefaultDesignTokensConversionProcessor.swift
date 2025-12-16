//
//  DefaultDesignTokensConversionProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming

extension TokenProcessor where Self == CombineProcessor {
    public static func defaultDesignTokensConversionProcessor(
        dimensionValueEvaluation dimensionValueEvaluationProcessor: DimensionValueEvaluationProcessor =
            .arithmeticalEvaluation,
        flattening flatteningProcessor: FlattenProcessor = .defaultDesignTokensFlatteingProcessor,
        dimensionValueConversion dimensionValueConversionProcessor: DimensionValueConversionProcessor =
            .defaultDesignTokensDimensionValueConversionProcessor
    ) -> CombineProcessor {
        .combine(
            .resolveAliases,
            dimensionValueEvaluationProcessor,
            flatteningProcessor,
            .dimensionValueConversion(
                using: .converter(),
                targetUnit: .px
            )
        )
    }
}
