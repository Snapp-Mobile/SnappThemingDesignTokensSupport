//
//  DesignTokensNumberValueExtractor.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

extension DesignTokensTokenValueExtractor {
    static var number: Self {
        .init(\.metricsCache) { $0 }
    }
}
