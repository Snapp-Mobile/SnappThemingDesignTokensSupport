//
//  DesignTokensTokenValueExtractorTests.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 18.12.2025.
//

import Testing
import SnappDesignTokens

@testable import SnappThemingDesignTokensSupport

struct DesignTokensTokenValueExtractorTests {
    @Test
    func testTypeMistmatchErrorHandling() async throws {
        var caches = SnappThemingDeclarationCaches()
        let extractor = DesignTokensTokenValueExtractor.color(using: .argb)
        let tokenValue = TokenValue.number(0.5)
        #expect(throws: DesignTokensTokenValueExtractorError.typeMistamatch) {
            try extractor.extract(tokenValue, for: "key", into: &caches)
        }
    }
}
