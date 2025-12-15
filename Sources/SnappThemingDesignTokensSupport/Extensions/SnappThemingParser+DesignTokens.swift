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
        if #available(iOS 17, *) {
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
