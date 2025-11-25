//
//  File.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import SnappTheming

extension SnappThemingDeclaration {
    init(
        caches: SnappThemingDeclarationCaches,
        using configuration: SnappThemingParserConfiguration
    ) {
        self.init(
            imageCache: caches.imageCache.isEmpty ? nil : caches.imageCache,
            colorCache: caches.colorCache.isEmpty ? nil : caches.colorCache,
            metricsCache: caches.metricsCache.isEmpty ? nil : caches.metricsCache,
            fontsCache: caches.fontsCache.isEmpty ? nil : caches.fontsCache,
            typographyCache: caches.typographyCache.isEmpty ? nil : caches.typographyCache,
            interactiveColorsCache: caches.interactiveColorsCache.isEmpty ? nil : caches.interactiveColorsCache,
            buttonStylesCache: caches.buttonStylesCache.isEmpty ? nil : caches.buttonStylesCache,
            shapeInformation: caches.shapeInformation.isEmpty ? nil : caches.shapeInformation,
            gradientsCache: caches.gradientsCache.isEmpty ? nil : caches.gradientsCache,
            segmentControlStyleCache: caches.segmentControlStyleCache.isEmpty ? nil : caches.segmentControlStyleCache,
            sliderStyleCache: caches.sliderStyleCache.isEmpty ? nil : caches.sliderStyleCache,
            toggleStyleCache: caches.toggleStyleCache.isEmpty ? nil : caches.toggleStyleCache,
            animationCache: caches.animationCache.isEmpty ? nil : caches.animationCache,
            using: configuration
        )
    }
}
