//
//  ColorHexFormatConversionTests.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens
import SnappTheming
import Testing

@testable import SnappThemingDesignTokensSupport

struct ColorHexFormatConversionTests {
    @Test("Converting ARGB format from SnappDesignTokens to SnappTheming")
    func testARGBConversion() {
        let colorHexFormat = ColorHexFormat.argb
        let result = colorHexFormat.snappThemingColorFormat

        if case .argb = result {
            // The conversion is correct.
        } else {
            Issue.record("Expected .argb conversion, but received \(result).")
        }
    }

    @Test("Converting RGBA format from SnappDesignTokens to SnappTheming")
    func testRGBAConversion() {
        let colorHexFormat = ColorHexFormat.rgba
        let result = colorHexFormat.snappThemingColorFormat

        if case .rgba = result {
            // The conversion is correct.
        } else {
            Issue.record("Expected .rgba conversion, but received \(result).")
        }
    }
}
