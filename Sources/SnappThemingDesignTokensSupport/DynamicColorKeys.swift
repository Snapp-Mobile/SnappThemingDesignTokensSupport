//
//  DynamicColorKeys.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

public struct DynamicColorKeys: Equatable, Sendable {
    public static let `default` = DynamicColorKeys(light: "light", dark: "dark")

    public let light: String
    public let dark: String

    public init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }
}
