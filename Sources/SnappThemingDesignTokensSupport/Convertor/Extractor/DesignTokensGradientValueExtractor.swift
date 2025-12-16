//
//  DesignTokensGradientValueExtractor.swift
//
//  Created by Volodymyr Voiko on 17.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

extension DesignTokensTokenValueExtractor {
    private enum GradientExtractionError: Error {
        case unresolvedReferences
    }

    static func gradient(using format: ColorHexFormat) -> Self {
        .init(\.gradientsCache) { (value: GradientValue) in
            let colorsWithPositions = try value.map { gradientColorValue in
                guard
                    case .value(let color) = gradientColorValue.color,
                    case .value(let position) = gradientColorValue.position
                else {
                    throw GradientExtractionError.unresolvedReferences
                }
                return (
                    color,
                    position
                )
            }

            let sortedColorTokens =
                try colorsWithPositions
                .sorted(by: { $0.1 < $1.1 })
                .map(\.0)
                .map { try $0.hex(format: format, skipFullOpacityAlpha: true) }
                .map(SnappThemingColorRepresentation.hex(_:))
                .map(SnappThemingToken.value(_:))

            return SnappThemingGradientRepresentation(
                configuration: SnappThemingLinearGradientRepresentation(
                    colors: sortedColorTokens,
                    startPoint: .init(value: .leading),
                    endPoint: .init(value: .trailing)
                )
            )
        }
    }
}
