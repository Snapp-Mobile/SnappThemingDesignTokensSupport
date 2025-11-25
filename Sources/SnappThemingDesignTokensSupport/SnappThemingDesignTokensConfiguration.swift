//
//  SnappThemingDesignTokensConfiguration.swift
//
//  Created by Ilian Konchev on 28.02.25.
//

import Foundation
import SnappDesignTokens

public struct SnappThemingDesignTokensConfiguration: Sendable {
    let assetsManager: AssetsManager
    let assetsSourceLocationURL: URL?
    /// The value 1rem represents
    let remBaseValue: Double
    private(set) var skipTokenSets: [String]
    private(set) var inputProcessors: [any TokenProcessor] = []
    private(set) var outputProcessors: [any TokenProcessor] = []

    public init(
        themeName: String = "default",
        skipTokenSets: [String] = [],
        assetsSourceLocationURL: URL? = nil,
        remBaseValue: Double = 16
    ) {
        self.skipTokenSets = skipTokenSets
        self.assetsManager = .init(themeName: themeName)
        self.assetsSourceLocationURL = assetsSourceLocationURL
        self.remBaseValue = remBaseValue
    }

    /// Key used to pass parser configuration through `JSONDecoder` or `JSONEncoder` user info.
    public static var userInfoKey: CodingUserInfoKey {
        return CodingUserInfoKey(rawValue: "designTokensConfiguration")!
    }

    public mutating func addInputProcessor(_ processor: some TokenProcessor) {
        inputProcessors.append(processor)
    }

    public mutating func addOutputProcessor(_ processor: some TokenProcessor) {
        outputProcessors.append(processor)
    }
}

extension SnappThemingDesignTokensConfiguration {
    public static func `default`(base configuration: SnappThemingDesignTokensConfiguration = .init()) -> Self {
        var configuration = configuration

        configuration.addOutputProcessor(.resolveAliases)

        configuration.addOutputProcessor(.arithmeticalEvaluation)

        configuration.addOutputProcessor(
            .dimensionValueConversion(
                using: .converter(with: configuration.remBaseValue),
                targetUnit: .px
            )
        )

        return configuration
    }
}
