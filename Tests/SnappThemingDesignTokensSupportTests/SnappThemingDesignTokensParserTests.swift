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
import UniformTypeIdentifiers

@testable import SnappThemingDesignTokensSupport

struct SnappThemingDesignTokensParserTests {
    @Test(
        arguments: [
            (
                #"""
                {"red": {"$type": "color", "$value": "#FF0000"}}
                """#,
                #"""
                {
                  "colors" : {
                    "red" : "#FF0000"
                  }
                }
                """#
            ),
            (
                #"""
                {
                  "red": {"$type": "color", "$value": "#FF0000"},
                  "unsupported": {"$type": "fontWeight", "$value": 350}
                }
                """#,
                #"""
                {
                  "colors" : {
                    "red" : "#FF0000"
                  }
                }
                """#
            ),
        ] as [(String, String)]
    )
    func testSuccessfulParsingDesignTokensJSONIntoSnappThemingDeclaration(
        _ designTokensJSON: String,
        _ expectedSnappThemingJSON: String
    ) async throws {
        let declaration = try await SnappThemingParser.parse(
            fromDesignTokens: designTokensJSON,
            designTokensConverterConfiguration: DesignTokensConverter.Configuration(
                unsupportedTokenHandlingStrategy: .skip
            )
        )
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
                {"unsupported": []}
                """#,
                DesignTokensConverter.Error.unsupportedToken(
                    .array([]),
                    forKey: "unsupported"
                )
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
            (
                #"""
                {
                    "expression": {
                        "$type": "dimension",
                        "$value": "2 * 10px"
                    }
                }
                """#,
                DesignTokensDimensionValueExtractorError.unresolvedExpression(
                    DimensionExpression(elements: [
                        .value(2), .multiply, .value(10, .px)
                    ])
                )
            ),
            (
                #"""
                {
                    "typography": {
                        "$type": "typography",
                        "$value": {
                            "fontFamily": "{reference}",
                            "fontSize": "{reference}",
                            "fontWeight": "{reference}",
                            "letterSpacing": "{reference}",
                            "lineHeight": "{reference}"
                        }

                    }
                }
                """#,
                DesignTokensTypographyValueExtractorError.unresolvedReferences
            ),
            (
                #"""
                {
                    "typography": {
                        "$type": "typography",
                        "$value": {
                            "fontFamily": "Arial",
                            "fontSize": "2 * 10px",
                            "fontWeight": 700,
                            "letterSpacing": "0.1px",
                            "lineHeight": 1.2
                        }

                    }
                }
                """#,
                DesignTokensTypographyValueExtractorError.unresolvedExpressions
            ),
            (
                #"""
                {
                    "typography": {
                        "$type": "typography",
                        "$value": {
                            "fontFamily": "Arial",
                            "fontSize": "10rem",
                            "fontWeight": 700,
                            "letterSpacing": "0.1px",
                            "lineHeight": 1.2
                        }

                    }
                }
                """#,
                DesignTokensTypographyValueExtractorError.invalidFontSizeUnit
            ),
            (
                #"""
                {
                    "typography": {
                        "$type": "typography",
                        "$value": {
                            "fontFamily": [],
                            "fontSize": "10px",
                            "fontWeight": 700,
                            "letterSpacing": "0.1px",
                            "lineHeight": 1.2
                        }

                    }
                }
                """#,
                DesignTokensTypographyValueExtractorError.fontsEmpty
            ),
            (
                #"""
                {
                    "blue-to-red": {
                        "$type": "gradient",
                        "$value": [
                            {
                                "color": "{color}",
                                "position": 0
                            }
                        ]
                    }
                }
                """#,
                DesignTokensGradientValueExtractionError.unresolvedReferences
            ),
            (
                #"""
                {
                    "unknown": {
                        "$type": "file",
                        "$value": "unknown"
                    }
                }
                """#,
                DesignTokensFileValueExtractorError.unknownFileType(
                    Bundle.module.resourceURL!.appendingPathComponent("unknown")
                )
            ),
            (
                #"""
                {
                    "unknown": {
                        "$type": "file",
                        "$value": "unsupported.extension"
                    }
                }
                """#,
                DesignTokensFileValueExtractorError.unsupportedFileType(
                    Bundle.module.resourceURL!.appendingPathComponent(
                        "unsupported.extension"
                    ),
                    UTType(filenameExtension: "extension")!
                )
            ),
            (
                #"""
                {
                    "empty": {
                        "$type": "fontFamily",
                        "$value": []
                    }
                }
                """#,
                DesignTokensFontFamilyValueExtractionError.fontsEmpty
            ),
            (
                #"""
                {
                    "malformed": {
                        "light_color": {"$type": "color", "$value": "#FFFFFF"},
                        "dark_color": {"$type": "color", "$value": "#000000"}
                    }
                }
                """#,
                DesignTokensConverter.Error.malformedDynamicColorsGroup(
                    [
                        "light_color": .value(.color(.white)),
                        "dark_color": .value(.color(.black)),
                    ],
                    forKey: "malformed"
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
                tokenDecodingConfiguration: TokenDecodingConfiguration(
                    file: .testResources
                ),
                tokenProcessor: .passthrough,
                designTokensConverterConfiguration: configuration
            )
        }
    }

    @Test(
        "Test FontWeight to FontPostscriptName mapping during parsing DesignTokens JSON into SnappThemingDeclaration",
        arguments: [
            (nil, "Arial"),
            ([100: "Thin"], "Arial-Thin"),
        ] as [(FontWeightMapping?, String)]
    )
    func testSuccessfulFontWeightToFontPostscriptNameMapping(
        fontWeightMapping: FontWeightMapping?,
        expectedPostscriptName: String
    ) async throws {
        let configuration = DesignTokensConverter.Configuration(
            fontWeightMapping: fontWeightMapping
        )
        let declaration = try await SnappThemingParser.parse(
            fromDesignTokens: #"""
            {
                "typography": {
                    "$type": "typography",
                    "$value": {
                        "fontFamily": ["Arial"],
                        "fontSize": "10px",
                        "fontWeight": 100,
                        "letterSpacing": "0.1px",
                        "lineHeight": 1.2
                    }

                }
            }
            """#,
            designTokensConverterConfiguration: configuration
        )
        let representation: SnappThemingTypographyRepresentation = try #require(declaration.typography.typography)
        #expect(representation.font.value?.postScriptName == expectedPostscriptName)
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
