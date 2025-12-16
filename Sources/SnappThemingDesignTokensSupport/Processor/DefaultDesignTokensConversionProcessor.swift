//
//  DefaultDesignTokensConversionProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming

extension TokenProcessor where Self == CombineProcessor {
    /// Provides a default `CombineProcessor` for converting a raw design token hierarchy into a processed format.
    ///
    /// This processor combines several essential steps into a single pipeline, simplifying the token conversion process.
    ///
    /// - Parameters:
    ///   - dimensionValueEvaluationProcessor: The processor for evaluating dimension value expressions. Defaults to `.arithmeticalEvaluation`.
    ///   - flatteningProcessor: The processor for flattening the token hierarchy. Defaults to ``.defaultDesignTokensFlatteingProcessor``.
    ///   - dimensionValueConversionProcessor: The processor for converting dimension values to a target unit. Defaults to ``.defaultDesignTokensDimensionValueConversionProcessor``.
    /// - Returns: A `CombineProcessor` that performs the following steps in order:
    ///   1.  Resolves all token aliases.
    ///   2.  Evaluates dimension value expressions.
    ///   3.  Flattens the token hierarchy.
    ///   4.  Converts all dimension values to a consistent target unit (`.px`).
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
