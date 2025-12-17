//
//  DesignTokensTypographyValueExtractor.swift
//
//  Created by Volodymyr Voiko on 17.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

enum DesignTokensTypographyValueExtractorError: Error, Equatable, Sendable {
    case unresolvedReferences
    case unresolvedExpressions
    case invalidFontSizeUnit
    case fontsEmpty
}

extension DesignTokensTokenValueExtractor {
    static func typography(
        fontWeightMapping: FontWeightMapping? = nil
    ) -> Self {
        .init(\.typographyCache) { (value: TypographyValue) in
            guard
                case .value(let fontFamilyValue) = value.fontFamily,
                case .value(let fontWeight) = value.fontWeight,
                case .value(let fontSizeValue) = value.fontSize
            else {
                throw DesignTokensTypographyValueExtractorError
                    .unresolvedReferences
            }

            guard let fontFamilyName = fontFamilyValue.names.first else {
                throw DesignTokensTypographyValueExtractorError.fontsEmpty
            }

            guard case .constant(let fontSize) = fontSizeValue else {
                throw DesignTokensTypographyValueExtractorError
                    .unresolvedExpressions
            }

            guard fontSize.unit == .px else {
                throw DesignTokensTypographyValueExtractorError
                    .invalidFontSizeUnit
            }

            var fontName = fontFamilyName
            if let fontWeightSuffix = fontWeightMapping?[fontWeight.rawValue]?
                .trimmingCharacters(in: .whitespaces),
                !fontWeightSuffix.isEmpty
            {
                fontName += "-\(fontWeightSuffix)"
            }

            return SnappThemingTypographyRepresentation(
                font: .value(
                    SnappThemingFontInformation(
                        postScriptName: fontName,
                        source: nil
                    )
                ),
                fontSize: .value(fontSize.value)
            )
        }
    }
}
