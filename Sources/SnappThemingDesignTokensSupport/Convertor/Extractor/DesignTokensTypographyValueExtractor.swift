//
//  DesignTokensTypographyValueExtractor.swift
//
//  Created by Volodymyr Voiko on 17.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

extension DesignTokensTokenValueExtractor {
    private enum TypographyExtractionError: Error {
        case unresolvedReferences
        case unresolvedExpressions
        case invalidFontSizeUnit
        case fontsEmpty
    }

    static func typography(
        fontWeightMapping: [FontWeightValue.RawValue: String]? = nil
    ) -> Self {
        .init(\.typographyCache) { (value: TypographyValue) in
            guard
                case .value(let fontFamilyValue) = value.fontFamily,
                case .value(let fontWeight) = value.fontWeight,
                case .value(let fontSizeValue) = value.fontSize
            else {
                throw TypographyExtractionError.unresolvedReferences
            }

            guard let fontFamilyName = fontFamilyValue.names.first else {
                throw TypographyExtractionError.fontsEmpty
            }

            guard case .constant(let fontSize) = fontSizeValue else {
                throw TypographyExtractionError.unresolvedExpressions
            }

            guard fontSize.unit == .px else {
                throw TypographyExtractionError.invalidFontSizeUnit
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
