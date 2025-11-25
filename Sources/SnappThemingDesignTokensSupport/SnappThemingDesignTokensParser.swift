//
//  SnappThemingDesignTokensParser.swift
//
//  Created by Ilian Konchev on 28.02.25.
//

import Foundation
import OSLog
import SnappDesignTokens

/// An error type representing issues encountered during theme parsing.
public enum SnappThemingDesignTokensParserError: Error {
    /// Indicates that the provided data is invalid or cannot be processed.
    case invalidData
}

public struct SnappThemingDesignTokensParser {
    static func parse<T: Decodable>(from input: String, using configuration: SnappThemingDesignTokensConfiguration)
        async throws -> T
    {
        guard let data = input.data(using: .utf8) else {
            throw SnappThemingDesignTokensParserError.invalidData
        }

        let decoder = JSONDecoder()
        decoder.userInfo[SnappThemingDesignTokensConfiguration.userInfoKey] = configuration

        do {
            var base = try decoder.decode(T.self, from: data)
            for processor in configuration.inputProcessors {
                if let input = base as? Token, let transformed = try await processor.process(input) as? T {
                    base = transformed
                }
            }
            return base
        } catch {
            os_log(.error, "Failed to parse JSON: %@", error.localizedDescription)
            throw error
        }
    }

    static func encode<T: Encodable>(_ token: T, using configuration: SnappThemingDesignTokensConfiguration)
        async throws -> Data
    {
        let encoder = JSONEncoder()
        encoder.userInfo[SnappThemingDesignTokensConfiguration.userInfoKey] = configuration
        if var base = token as? Token {
            for processor in configuration.outputProcessors {
                base = try await processor.process(base)
            }
            return try encoder.encode(base)
        } else {
            return try encoder.encode(token)
        }
    }

    static func cleanup(using configuration: SnappThemingDesignTokensConfiguration) async throws {
        try await configuration.assetsManager.cleanup()
    }
}
