//
//  ContentView.swift
//  Example
//
//  Created by Volodymyr Voiko on 19.12.2025.
//

import SnappDesignTokens
import SnappTheming
import SnappThemingDesignTokensSupport
import SwiftUI

struct ContentView: View {
    @State var themeDeclaration: SnappThemingDeclaration?

    var body: some View {
        if let themeDeclaration {
            content(themeDeclaration)
        } else {
            ProgressView()
                .progressViewStyle(.circular)
                .task {
                    await loadThemeDeclaration()
                }
        }
    }

    func content(_ theme: SnappThemingDeclaration) -> some View {
        NavigationStack {
            List {
                Section {
                    ForEach(theme.colors.keys, id: \.self) { key in
                        LabeledContent(key) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(theme.colors[dynamicMember: key])
                                .frame(width: 40, height: 40)
                                .shadow(color: .black.opacity(0.3), radius: 2)
                        }
                    }
                } header: {
                    Text("Colors")
                }

                Section {
                    ForEach(theme.metrics.keys, id: \.self) { key in
                        let value: CGFloat = theme.metrics[dynamicMember: key]
                        LabeledContent(key) {
                            HStack {
                                Text(String(String(describing: value)))
                                ZStack {
                                    UnevenRoundedRectangle(
                                        topLeadingRadius: value
                                    )
                                    .fill(Color.gray)
                                    .padding([.top, .leading], value)
                                }
                                .frame(width: 40, height: 40)
                                .background(Color.gray.secondary)
                            }
                        }
                    }
                } header: {
                    Text("Metrics")
                }

                Section {
                    ForEach(theme.fonts.keys, id: \.self) { key in
                        let fontInformation: SnappThemingFontInformation? = theme.fonts[dynamicMember: key]
                        Text(fontInformation?.postScriptName ?? key)
                            .font(fontInformation?.resolver.font(size: 16))
                    }
                } header: {
                    Text("Fonts")
                }

                Section {
                    ForEach(theme.typography.keys, id: \.self) { key in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(key)
                            Text(
                                "Lorem ipsum dolor sit amet, consectetur adipiscing elit."
                            )
                            .font(theme.typography[dynamicMember: key])
                        }
                    }
                } header: {
                    Text("Typography")
                }
            }
            .background(theme.colors.colorBackgroundPrimary)
            .navigationTitle("Design Tokens Viewer")
            .navigationBarTitleDisplayMode(.inline)
        }
        .foregroundStyle(theme.colors.colorTextPrimary)
    }

    func loadThemeDeclaration() async {
        let designTokensURL = Bundle.main.url(
            forResource: "design.tokens",
            withExtension: "json"
        )!
        let designTokens = try! String(
            contentsOf: designTokensURL,
            encoding: .utf8
        )

        themeDeclaration = try! await SnappThemingParser.parse(
            fromDesignTokens: designTokens,
            tokenProcessor: .combine(
                .resolveAliases,
                .skipKeys("base"),
                .defaultDesignTokensFlatteingProcessor,
                .defaultDesignTokensDimensionValueConversionProcessor
            )
        )
    }
}

#Preview("Light") {
    ContentView()
        .colorScheme(.light)
}

#Preview("Dark") {
    ContentView()
        .colorScheme(.dark)
}
