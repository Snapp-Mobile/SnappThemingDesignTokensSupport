//
//  DynamicColorKeys.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

/// A struct that encapsulates the keys used to identify light and dark color modes within dynamic color definitions.
///
/// This allows for flexible mapping of design token colors to different appearances (e.g., light mode, dark mode)
/// by providing the specific string keys associated with each mode.
public struct DynamicColorKeys: Equatable, Sendable {
    /// The default `DynamicColorKeys` instance, using "light" for the light mode key and "dark" for the dark mode key.
    public static let `default` = DynamicColorKeys(light: "light", dark: "dark")

    /// The string key used to identify the light color mode.
    public let light: String
    /// The string key used to identify the dark color mode.
    public let dark: String

    /// Initializes a new `DynamicColorKeys` instance with specified keys for light and dark color modes.
    /// - Parameters:
    ///   - light: The string key for the light color mode.
    ///   - dark: The string key for the dark color mode.
    public init(light: String, dark: String) {
        self.light = light
        self.dark = dark
    }
}
