//
//  Bundle+JSON.swift
//  SnappThemingDesignTokensSupport
//
//  Created by Volodymyr Voiko on 28.11.2025.
//

import Foundation
import Testing

extension Bundle {
    func loadJSON(
        filename: String,
        trimCharacters characterSet: CharacterSet = .whitespacesAndNewlines
    ) throws -> String {
        let fileURL = try #require(url(forResource: filename, withExtension: "json"))

        let json = try String(contentsOf: fileURL, encoding: .utf8)
        return json.trimmingCharacters(in: characterSet)
    }
}
