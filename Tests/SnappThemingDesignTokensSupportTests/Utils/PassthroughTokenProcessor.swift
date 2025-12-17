//
//  TokenProcessor+PassthroughTokenProcessor.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 17.12.2025.
//

import SnappDesignTokens

struct PassthroughTokenProcessor: TokenProcessor {
    init() {}

    func process(_ token: Token) async throws -> Token { token }
}

extension TokenProcessor where Self == PassthroughTokenProcessor {
    static var passthrough: Self { PassthroughTokenProcessor() }
}
