//
//  DesignTokensColorValueExtractor.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

extension DesignTokensTokenValueExtractor {
    static func color(using format: SnappThemingColorFormat) -> Self {
        .init(\.colorCache) { (value: ColorValue) in
            try .hex(value.hexString(using: format))
        }
    }
}
