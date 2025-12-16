//
//  ColorHexFormat+SnappThemingColorFormat.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming

extension ColorHexFormat {
    var snappThemingColorFormat: SnappThemingColorFormat {
        switch self {
        case .argb: .argb
        case .rgba: .rgba
        }
    }
}
