//
//  SnappThemingDeclarationConverter.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import OSLog
import SnappDesignTokens
import SnappTheming

public struct SnappThemingDeclarationConverter {
    public struct AdaptiveColorKeys: Equatable, Sendable {
        public static let `default` = AdaptiveColorKeys(light: "light", dark: "dark")

        public let light: String
        public let dark: String

        public init(light: String, dark: String) {
            self.light = light
            self.dark = dark
        }
    }

    public let configuration: SnappThemingParserConfiguration
    public let fontWeightMapping: [FontWeightValue.RawValue: String]?
    public let adaptiveColorKeys: AdaptiveColorKeys

    public init(
        configuration: SnappThemingParserConfiguration,
        fontWeightMapping: [FontWeightValue.RawValue: String]? = nil,
        adaptiveColorKeys: AdaptiveColorKeys = .default
    ) {
        self.configuration = configuration
        self.fontWeightMapping = fontWeightMapping
        self.adaptiveColorKeys = adaptiveColorKeys
    }

    public func convert(
        _ token: Token
    ) async throws -> SnappThemingDeclaration {
        var caches = SnappThemingDeclarationCaches()

        if case .group(let group) = token {
            try await extract(group, into: &caches)
        }

        return SnappThemingDeclaration(
            caches: caches,
            using: configuration
        )
    }

    private func extract(
        _ group: TokenGroup,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        for (key, token) in group {
            try await extract(token, for: key, into: &caches)
        }
    }

    private func extract(
        _ token: Token,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        switch token {
        case .value(let value):
            try await extract(value, for: key, into: &caches)
        case .group(let group):
            try await extract(group, for: key, into: &caches)
        case .alias, .array, .unknown:
            break
        }
    }

    private func extract(
        _ value: TokenValue,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        guard let extractor = extractorFor(value) else { return }
        try extractor.extract(value, for: key, into: &caches)
    }

    private func extract(
        _ group: TokenGroup,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) async throws {
        guard
            case .value(.color(let lightColorToken)) = group[adaptiveColorKeys.light],
            case .value(.color(let darkColorToken)) = group[adaptiveColorKeys.dark]
        else {
            return
        }

        let lightColorHEX = try lightColorToken.hexString(using: configuration.colorFormat)
        let darkColorHEX = try darkColorToken.hexString(using: configuration.colorFormat)

        let dynamicColor = SnappThemingDynamicColor(
            light: lightColorHEX,
            dark: darkColorHEX
        )

        caches.colorCache[key] = .value(.dynamic(dynamicColor))
    }

    private func extractorFor(
        _ value: TokenValue
    ) -> DesignTokensTokenValueExtractor? {
        switch value {
        case .color:
            return .color(using: configuration.colorFormat)
        case .dimension:
            return .dimension
        case .file:
            return .file
        case .fontFamily:
            return .fontFamily
        case .typography:
            return .typography(fontWeightMapping: fontWeightMapping)
        case .gradient:
            return .gradient(using: configuration.colorFormat)
        case .fontWeight, .number,
            .duration, .shadow, .strokeStyle, .border,
            .cubicBezier, .transition:
            fallthrough
        default:
            os_log(.debug, "Unsupported token type")
        }
        return nil
    }
}
