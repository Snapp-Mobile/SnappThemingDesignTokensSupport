//
//  FileValueDecodingConfiguration+TestResources.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 15.12.2025.
//

import Foundation
import SnappDesignTokens

extension FileValueDecodingConfiguration {
    static let testResources = Self(source: Bundle.module.resourceURL)
}
