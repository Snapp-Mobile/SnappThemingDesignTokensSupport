//
//  DesignTokensTokenValueExtractor.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming

enum DesignTokensTokenValueExtractorError: Error, Equatable {
    case typeMistamatch
}

struct DesignTokensTokenValueExtractor {
    private let extracting:
        (
            _ value: TokenValue,
            _ key: String,
            _ caches: inout SnappThemingDeclarationCaches
        ) throws -> Void

    init(
        _ extracting:
            @escaping (
                _ value: TokenValue,
                _ key: String,
                _ caches: inout SnappThemingDeclarationCaches
            ) throws -> Void
    ) {
        self.extracting = extracting
    }

    init<Value>(
        _ extracting:
            @escaping (
                _ value: Value,
                _ key: String,
                _ caches: inout SnappThemingDeclarationCaches
            ) throws -> Void
    ) {
        self.init { value, key, caches in
            guard let extractedValue = value.anyValue as? Value else {
                throw DesignTokensTokenValueExtractorError.typeMistamatch
            }
            try extracting(extractedValue, key, &caches)
        }
    }

    init<Value, Representation>(
        _ keyPath: WritableKeyPath<
            SnappThemingDeclarationCaches,
            [String: SnappThemingToken<Representation>]
        >,
        _ transform: @escaping (Value) throws -> Representation
    ) where Representation: Decodable, Representation: Encodable {
        self.init { value, key, caches in
            let representation = try transform(value)
            caches[keyPath: keyPath][key] = .value(representation)
        }
    }

    func extract(
        _ value: TokenValue,
        for key: String,
        into caches: inout SnappThemingDeclarationCaches
    ) throws {
        try extracting(value, key, &caches)
    }
}
