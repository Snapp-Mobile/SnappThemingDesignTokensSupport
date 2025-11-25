//
//  DesignTokensFontFamilyValueExtractor.swift
//
//  Created by Volodymyr Voiko on 16.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

extension DesignTokensTokenValueExtractor {
    private enum DesignTokensFontFamilyExtractionError: Error {
        case fontsEmpty
    }

    static var fontFamily: Self {
        .init(\.fontsCache) { (value: FontFamilyValue) in
            /// As a [translation tool](https://tr.designtokens.org/format/#translation-tool) we
            /// decide how to convert types.
            /// So when we convert to SnappTheming (which does't support multiple fonts),
            /// we will just try to use the primary font and ignore fallbacks.
            /// OS will just provided system font as fallback if required font is not available.
            guard let fontName = value.names.first else {
                throw DesignTokensFontFamilyExtractionError.fontsEmpty
            }
            return SnappThemingFontInformation(postScriptName: fontName, source: nil)
        }
    }
}
