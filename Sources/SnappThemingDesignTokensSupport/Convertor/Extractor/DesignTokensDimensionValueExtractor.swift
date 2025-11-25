//
//  DesignTokensDimensionValueExtractor.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

enum DesignTokensDimensionValueExtractorError: Error, Equatable {
    case unresolvedExpression(DimensionExpression)
}

extension DesignTokensTokenValueExtractor {
    static var dimension: Self {
        .init(\.metricsCache) { (value: DimensionValue) in
            switch value {
            case .constant(let constant):
                return constant.value
            case .expression(let expression):
                throw DesignTokensDimensionValueExtractorError.unresolvedExpression(
                    expression
                )
            }
        }
    }
}
