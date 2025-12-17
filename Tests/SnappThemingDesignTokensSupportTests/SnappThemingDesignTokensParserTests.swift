//
//  SnappThemingDesignTokensParserTests.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming
import Testing

@testable import SnappThemingDesignTokensSupport

struct SnappThemingDesignTokensParserTests {
    @Test(
        arguments: [
            (
                #"""
                {
                  "red": {
                    "$type": "color",
                    "$value": "#FF0000"
                  }
                }
                """#,
                #"""
                {
                  "colors" : {
                    "red" : "#FF0000"
                  }
                }
                """#
            )
        ] as [(String, String)]
    )
    func testSuccessfulParsingDesignTokensJSONIntoSnappThemingDeclaration(
        _ designTokensJSON: String,
        _ expectedSnappThemingJSON: String
    ) async throws {
        let declaration = try await SnappThemingParser.parse(fromDesignTokens: designTokensJSON)
        let encodedSnappThemingData = try SnappThemingParser.encode(declaration)
        let encodedSnappThemingJSON = try #require(String(data: encodedSnappThemingData, encoding: .utf8))
        #expect(encodedSnappThemingJSON == expectedSnappThemingJSON)
    }

    @Test(
        arguments: [
            (
                #"""
                []
                """#,
                DesignTokensConverter.Error.invalidRootToken
            ),
            (
                #"""
                {
                    "unsupported": {
                        "$type": "number",
                        "$value": 0.5
                    }
                }
                """#,
                DesignTokensConverter.Error.unsupportedToken(
                    .value(.number(0.5)),
                    forKey: "unsupported"
                )
            ),
        ] as [(String, Error)]
    )
    func testFailingParsingDesignTokensJSONIntoSnappThemingDeclaration(
        _ designTokensJSON: String,
        _ expectedError: Error
    ) async throws {
        let configuration = DesignTokensConverter.Configuration(
            unsupportedTokenHandlingStrategy: .fail
        )
        await #expect(throws: expectedError as NSError) {
            try await SnappThemingParser.parse(
                fromDesignTokens: designTokensJSON,
                designTokensConverterConfiguration: configuration
            )
        }
    }

    @Test(
        arguments: [
            ("design.tokens", "expected.snapptheming")
        ]
    )
    func testSuccessfulParsingDesignTokensFileIntoSnappThemingDeclaration(
        _ designTokensFilename: String,
        _ expectedSnappThemingFilename: String
    ) async throws {
        let designTokensJSON = try Bundle.module.loadJSON(filename: designTokensFilename)
        let expectedSnappThemingJSON = try Bundle.module.loadJSON(filename: expectedSnappThemingFilename)

        let declaration = try await SnappThemingParser.parse(
            fromDesignTokens: designTokensJSON,
            tokenDecodingConfiguration: TokenDecodingConfiguration(
                file: .testResources
            )
        )

        let configuration = SnappThemingParserConfiguration(
            encodeFonts: true,
            encodeImages: true
        )
        let encodedSnappThemingData = try SnappThemingParser.encode(declaration, using: configuration)
        let encodedSnappThemingJSON = try #require(String(data: encodedSnappThemingData, encoding: .utf8))

        #expect(encodedSnappThemingJSON == expectedSnappThemingJSON)
    }
}
