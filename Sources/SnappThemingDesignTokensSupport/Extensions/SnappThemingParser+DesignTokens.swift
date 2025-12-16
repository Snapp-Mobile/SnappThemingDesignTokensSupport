//
//  SnappThemingDesignTokensParser.swift
//
//  Created by Ilian Konchev on 28.02.25.
//

import Foundation
import OSLog
import SnappDesignTokens
import SnappTheming

extension SnappThemingParser {
    /// Parses design tokens from a JSON string into a `SnappThemingDeclaration`.
    ///
    /// This static method provides a convenient way to integrate Design Tokens
    /// Community Group (DTCG) compliant design tokens into the SnappTheming system.
    /// It handles the decoding of the raw JSON string, an optional processing step
    /// (e.g., flattening), and conversion into a `SnappThemingDeclaration`.
    ///
    /// - Parameters:
    ///   - input: The JSON string containing the design tokens.
    ///   - tokenDecodingConfiguration: Configuration for decoding the raw design tokens.
    ///     Defaults to `.default`.
    ///   - processor: An optional `TokenProcessor` to modify the tokens before conversion.
    ///     Defaults to `.defaultDesignTokensConversionProcessor()`.
    ///   - configuration: Configuration for the `DesignTokensConverter`. Defaults to `.default`.
    /// - Returns: A `SnappThemingDeclaration` instance representing the parsed design tokens.
    /// - Throws:
    ///   - `SnappThemingParserError.invalidData` if the input string cannot be converted to data.
    ///   - `Swift.DecodingError` if the JSON data cannot be decoded into `Token` objects.
    ///   - `DesignTokensConverter.Error` if the conversion process encounters an unresolvable issue
    ///     (depending on the `unsupportedTokenHandlingStrategy` in the configuration).
    ///   - Any error thrown by the `TokenProcessor` during the processing step.
    public static func parse(
        fromDesignTokens input: String,
        tokenDecodingConfiguration: TokenDecodingConfiguration = .default,
        tokenProcessor processor: TokenProcessor = .defaultDesignTokensConversionProcessor(),
        designTokensConverterConfiguration configuration: DesignTokensConverter.Configuration = .default
    ) async throws -> SnappThemingDeclaration {
        guard let data = input.data(using: .utf8) else {
            throw SnappThemingParserError.invalidData
        }

        let decoder = JSONDecoder()
        let token: Token
        if #available(iOS 17, macOS 14, *) {
            token = try decoder.decode(
                Token.self,
                from: data,
                configuration: tokenDecodingConfiguration
            )
        } else {
            decoder.tokenDecodingConfiguration = tokenDecodingConfiguration
            token = try decoder.decode(Token.self, from: data)
        }

        let converter = DesignTokensConverter(configuration: configuration)
        do {
            let processedTokens = try await processor.process(token)
            let declaration = try await converter.convert(processedTokens)
            return declaration
        } catch {
            os_log(
                .error,
                "Failed to parse design tokens JSON: %@",
                error.localizedDescription
            )
            throw error
        }
    }
}
