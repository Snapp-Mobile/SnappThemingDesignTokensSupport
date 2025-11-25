//
//  SnappThemingDesignTokensParserProtocol.swift
//
//  Created by Oleksii Kolomiiets on 04.03.2025.
//

import Foundation
import OSLog
import SnappDesignTokens
import SnappTheming

public protocol SnappThemingDesignTokensParserProtocol {
    static func createDeclarationFromDesignTokensTokens(
        _ designTokens: String,
        using configuration: SnappThemingDesignTokensConfiguration,
        lightColorKey: String,
        darkColorKey: String
    ) async throws -> SnappThemingDeclaration
}

extension SnappThemingDesignTokensParser: SnappThemingDesignTokensParserProtocol {
    /// Parses Design Token Community Group (DesignTokens) tokens into a SnappThemingDeclaration.
    ///
    /// This parser processes DesignTokens-formatted design tokens by:
    /// - Resolving token aliases and references
    /// - Flattening nested token structures into a flat hierarchy
    /// - Extracting light and dark color mode variants
    ///
    /// - Parameters:
    ///   - designTokens: A JSON string containing DesignTokens-formatted design tokens conforming to the Design Tokens Community Group specification
    ///   - parsingConfig: Parser configuration settings. Defaults to standard DesignTokens parsing rules
    ///   - lightColorKey: The key used to identify light mode color values. Defaults to "light"
    ///   - darkColorKey: The key used to identify dark mode color values. Defaults to "dark"
    /// - Returns: A structured SnappThemingDeclaration containing parsed and flattened design tokens
    /// - Throws: Parser errors for malformed input, processing failures, or invalid token data
    public static func createDeclarationFromDesignTokensTokens(
        _ designTokens: String,
        using parsingConfig: SnappThemingDesignTokensConfiguration = .default(),
        lightColorKey: String = "light",
        darkColorKey: String = "dark"
    ) async throws
        -> SnappTheming.SnappThemingDeclaration
    {
        guard let designTokensData = designTokens.data(using: .utf8) else {
            throw SnappThemingDesignTokensParserError.invalidData
        }

        var designTokensToken = try JSONDecoder().decode(
            Token.self,
            from: designTokensData
        )

        let processor: TokenProcessor = .combine(
            .resolveAliases,
            .skipKeys(parsingConfig.skipTokenSets),
            .flatten(
                flatteningDepth: .limitWhere { group in
                    guard
                        case .value(.color) = group[lightColorKey],
                        case .value(.color) = group[darkColorKey]
                    else {
                        return false
                    }
                    return true
                }
            )
        )

        designTokensToken = try await processor.process(designTokensToken)

        let parserConfiguration = SnappThemingParserConfiguration(
            colorFormat: .argb
        )
        let converter = SnappThemingDeclarationConverter(
            configuration: parserConfiguration,
            adaptiveColorKeys: .init(light: lightColorKey, dark: darkColorKey)
        )

        return try await converter.convert(designTokensToken)
    }
}
