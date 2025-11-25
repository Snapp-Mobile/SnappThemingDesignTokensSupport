//
//  ColorValue+Extensions.swift
//
//  Created by Volodymyr Voiko on 17.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

public enum SnappThemingDesignTokensColorConversionError: Error {
    case unsupportedColorSpace(TokenColorSpace)
    case invalidColorComponents([ColorComponent])
}

extension ColorValue {
    public func hexString(using format: SnappThemingColorFormat) throws -> String {
        return switch format {
        case .argb:
            try hex(format: .argb, skipFullOpacityAlpha: true)
        case .rgba:
            try hex(format: .rgba, skipFullOpacityAlpha: true)
        }
    }
}
