//
//  FontWeightMapping.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 26.11.2025.
//

import SnappDesignTokens

/// Type alias for a dictionary that maps ``SnappDesignTokens/FontWeightValue/RawValue`` (which represents a font weight from design tokens)
/// to a `String` that typically represents a platform-specific font weight name or a numerical value.
///
/// This mapping is crucial for apply design token font weights to the ``SnappTheming/SnappThemingFontInformation`` of the
/// ``SnappDesignTokens/FontFamilyValue`` when converting ``SnappDesignTokens/TypographyValue`` into
/// ``SnappTheming/SnappThemingTypographyRepresentation``.
/// It is used in `DesignTokensTypographyValueExtractor.swift` to construct `postScriptName` font names.
public typealias FontWeightMapping = [FontWeightValue.RawValue: String]
