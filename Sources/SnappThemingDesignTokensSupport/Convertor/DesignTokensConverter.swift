//
//  DesignTokensConverter.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 25.11.2025.
//

import Foundation
import OSLog
import SnappDesignTokens
import SnappTheming

public struct DesignTokensConverter: Sendable {
    public static let `default` = DesignTokensConverter()

    public enum Error: Equatable, Sendable, LocalizedError {
        case invalidRootToken
        case unsupportedToken(Token, forKey: String)

        var errorDescription: String {
            switch self {
            case .invalidRootToken: "Invalid root token. Must be a group."
            case let .unsupportedToken(_, key): "Unsupported token value type with key: \(key)."
            }
        }
    }

    public enum UnsupportedTokenHandlingStrategy: Equatable, Sendable {
        case skip
        case fail
    }

    public struct Configuration: Equatable, Sendable {
        public static let `default` = Configuration()

        public var colorHexFormat: ColorHexFormat = .default
        public var dynamicColorKeys: DynamicColorKeys = .default
        public var unsupportedTokenHandlingStrategy: UnsupportedTokenHandlingStrategy = .skip
        public var fontWeightMapping: FontWeightMapping? = nil

        public init(
            colorHexFormat: ColorHexFormat = .default,
            dynamicColorKeys: DynamicColorKeys = .default,
            unsupportedTokenHandlingStrategy: UnsupportedTokenHandlingStrategy = .skip,
            fontWeightMapping: FontWeightMapping? = nil
        ) {
            self.colorHexFormat = colorHexFormat
            self.dynamicColorKeys = dynamicColorKeys
            self.unsupportedTokenHandlingStrategy = unsupportedTokenHandlingStrategy
            self.fontWeightMapping = fontWeightMapping
        }
    }

    public let configuration: Configuration

    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }

    public func convert(_ token: Token) async throws -> SnappThemingDeclaration {
        guard case .group(let group) = token else {
            throw Error.invalidRootToken
        }

        var caches = SnappThemingDeclarationCaches()
        for (key, token) in group {
            do {
                try await extract(token, for: key, into: &caches)
            } catch {
                guard configuration.unsupportedTokenHandlingStrategy == .fail else {
                    continue
                }
                throw error
            }
        }

        let parserConfiguration = SnappThemingParserConfiguration(
            colorFormat: configuration.colorHexFormat.snappThemingColorFormat
        )

        return SnappThemingDeclaration(
            caches: caches,
            using: parserConfiguration
        )
    }

    private func extract(
        _ token: Token,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        switch token {
        case .value(let value):
            let extractor = try extractorFor(
                value,
                of: token,
                with: key
            )
            try extractor.extract(value, for: key, into: &caches)
        case .group(let group):
            try await extract(group, for: key, into: &caches)
        case .alias, .array, .unknown:
            throw Error.unsupportedToken(token, forKey: key)
        }
    }

    private func extract(
        _ group: TokenGroup,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        guard
            case .value(.color(let lightColorToken)) = group[configuration.dynamicColorKeys.light],
            case .value(.color(let darkColorToken)) = group[configuration.dynamicColorKeys.dark]
        else {
            return
        }

        let lightColorHEX = try lightColorToken.hex(
            format: configuration.colorHexFormat,
            skipFullOpacityAlpha: true
        )
        let darkColorHEX = try darkColorToken.hex(
            format: configuration.colorHexFormat,
            skipFullOpacityAlpha: true
        )

        let dynamicColor = SnappThemingDynamicColor(
            light: lightColorHEX,
            dark: darkColorHEX
        )

        caches.colorCache[key] = .value(.dynamic(dynamicColor))
    }

    private func extractorFor(
        _ value: TokenValue,
        of token: Token,
        with key: String
    ) throws -> DesignTokensTokenValueExtractor {
        switch value {
        case .color:
            return .color(using: configuration.colorHexFormat)
        case .dimension:
            return .dimension
        case .file:
            return .file
        case .fontFamily:
            return .fontFamily
        case .typography:
            return .typography(fontWeightMapping: configuration.fontWeightMapping)
        case .gradient:
            return .gradient(using: configuration.colorHexFormat)
        case .fontWeight, .number,
            .duration, .shadow, .strokeStyle, .border,
            .cubicBezier, .transition:
            fallthrough
        default:
            os_log(.debug, "Unsupported token value type for token with key: %@", key)
            throw Error.unsupportedToken(token, forKey: key)
        }
    }
}
