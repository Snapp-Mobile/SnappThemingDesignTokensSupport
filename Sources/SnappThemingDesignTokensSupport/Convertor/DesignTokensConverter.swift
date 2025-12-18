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

/// A utility struct responsible for converting design tokens conforming to the
/// Design Tokens Community Group (DTCG) standard into a `SnappThemingDeclaration`.
///
/// This converter processes raw `Token` objects, resolves aliases, handles
/// various token types (colors, dimensions, typography, etc.), and applies
/// specified configurations for hex color formats, dynamic color keys, and
/// unsupported token handling strategies.
public struct DesignTokensConverter: Sendable {
    /// The default `DesignTokensConverter` instance, initialized with default configurations.
    public static let `default` = DesignTokensConverter()

    /// Represents errors that can occur during the design token conversion process.
    public enum Error: Equatable, Sendable, LocalizedError {
        /// Indicates that the root token provided for conversion is not a group.
        case invalidRootToken
        /// Indicates that an unsupported token value type was encountered.
        /// - Parameters:
        ///   - token: The `Token` that could not be processed.
        ///   - forKey: The key associated with the unsupported token.
        case unsupportedToken(Token, forKey: String)
        case malformedDynamicColorsGroup(TokenGroup, forKey: String)

        /// A localized description of the error.
        public var errorDescription: String? {
            switch self {
            case .invalidRootToken: "Invalid root token. Must be a group."
            case let .unsupportedToken(_, key): "Unsupported token value type with key: \(key)."
            case let .malformedDynamicColorsGroup(_, key): "Malformed dynamic colors group for key: \(key)."
            }
        }
    }

    /// Defines the strategy for how the converter should handle unsupported token types.
    public enum UnsupportedTokenHandlingStrategy: Equatable, Sendable {
        /// Skips any unsupported tokens and continues the conversion process.
        case skip
        /// Stops the conversion process and throws an error if an unsupported token is encountered.
        case fail
    }

    /// Configuration options for the `DesignTokensConverter`.
    public struct Configuration: Equatable, Sendable {
        /// The default `Configuration` instance.
        public static let `default` = Configuration()

        /// The preferred hexadecimal format for color conversions.
        public var colorHexFormat: ColorHexFormat = .default
        /// Keys used to identify light and dark color modes for dynamic colors.
        public var dynamicColorKeys: DynamicColorKeys = .default
        /// The strategy to apply when encountering unsupported token types during conversion.
        public var unsupportedTokenHandlingStrategy: UnsupportedTokenHandlingStrategy = .skip
        /// An optional mapping for font weights, used in typography conversion.
        public var fontWeightMapping: FontWeightMapping? = nil

        /// Initializes a new `Configuration` instance with specified options.
        /// - Parameters:
        ///   - colorHexFormat: The preferred hexadecimal format for color conversions. Defaults to `.default`.
        ///   - dynamicColorKeys: Keys used to identify light and dark color modes. Defaults to `.default`.
        ///   - unsupportedTokenHandlingStrategy: The strategy for handling unsupported tokens. Defaults to `.skip`.
        ///   - fontWeightMapping: An optional mapping for font weights. Defaults to `nil`.
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

    /// The configuration applied to this converter instance.
    public let configuration: Configuration

    /// Initializes a new `DesignTokensConverter` with an optional custom configuration.
    /// - Parameter configuration: The configuration to use for the converter. Defaults to `.default`.
    public init(configuration: Configuration = .default) {
        self.configuration = configuration
    }

    /// Converts a given design token into a `SnappThemingDeclaration`.
    ///
    /// This method processes the token hierarchy, applying the configured strategies
    /// to extract and transform design token values into a format usable by `SnappTheming`.
    /// - Parameter token: The root `Token` representing the design token hierarchy.
    /// - Returns: A `SnappThemingDeclaration` instance derived from the input design tokens.
    /// - Throws: `DesignTokensConverter.Error` if the root token is invalid or if an
    ///   unsupported token is encountered and the `unsupportedTokenHandlingStrategy` is set to `.fail`.
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
                    os_log(.debug, "Skipping unsupported token: %{public}@", key)
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

    /// Extracts and processes a `Token` and its children, populating the caches.
    /// - Parameters:
    ///   - token: The `Token` to extract.
    ///   - key: The key associated with the token.
    ///   - caches: The `SnappThemingDeclarationCaches` to populate with extracted data.
    /// - Throws: `DesignTokensConverter.Error` if an unsupported token is encountered.
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
            try await extractDynamicColorsGroup(group, for: key, into: &caches)
        case .alias, .array, .unknown:
            throw Error.unsupportedToken(token, forKey: key)
        }
    }

    /// Extracts dynamic color information from a token group.
    ///
    /// This method looks for "light" and "dark" color tokens within a group
    /// based on `dynamicColorKeys` and converts them into a `SnappThemingDynamicColor`.
    /// - Parameters:
    ///   - group: The `TokenGroup` to extract dynamic colors from.
    ///   - key: The key associated with the token group.
    ///   - caches: The `SnappThemingDeclarationCaches` to store the dynamic color.
    /// - Throws: `DesignTokensConverter.Error` if color conversion fails.
    private func extractDynamicColorsGroup(
        _ group: TokenGroup,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        guard
            case .value(.color(let lightColorToken)) = group[
                configuration.dynamicColorKeys.light
            ],
            case .value(.color(let darkColorToken)) = group[
                configuration.dynamicColorKeys.dark
            ]
        else {
            throw Error.malformedDynamicColorsGroup(group, forKey: key)
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

    /// Returns the appropriate `DesignTokensTokenValueExtractor` for a given `TokenValue`.
    /// - Parameters:
    ///   - value: The `TokenValue` for which to get an extractor.
    ///   - token: The full `Token` object.
    ///   - key: The key associated with the token.
    /// - Returns: A `DesignTokensTokenValueExtractor` instance configured for the specific value type.
    /// - Throws: `DesignTokensConverter.Error.unsupportedToken` if no suitable extractor is found.
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
