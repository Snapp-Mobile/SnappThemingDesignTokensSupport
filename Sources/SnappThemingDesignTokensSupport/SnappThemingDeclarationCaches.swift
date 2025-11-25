//
//  SnappThemingDeclarationCaches.swift
//
//  Created by Volodymyr Voiko on 09.04.2025.
//

import SnappTheming

struct SnappThemingDeclarationCaches {
    var imageCache = [String: SnappThemingToken<String>]()
    var colorCache = [String: SnappThemingToken<SnappThemingColorRepresentation>]()
    var metricsCache = [String: SnappThemingToken<Double>]()
    var fontsCache = [String: SnappThemingToken<SnappThemingFontInformation>]()
    var typographyCache = [String: SnappThemingToken<SnappThemingTypographyRepresentation>]()
    var interactiveColorsCache = [String: SnappThemingToken<SnappThemingInteractiveColorInformation>]()
    var buttonStylesCache = [String: SnappThemingToken<SnappThemingButtonStyleRepresentation>]()
    var shapeInformation = [String: SnappThemingToken<SnappThemingShapeRepresentation>]()
    var gradientsCache = [String: SnappThemingToken<SnappThemingGradientRepresentation>]()
    var segmentControlStyleCache = [String: SnappThemingToken<SnappThemingSegmentControlStyleRepresentation>]()
    var sliderStyleCache = [String: SnappThemingToken<SnappThemingSliderStyleRepresentation>]()
    var toggleStyleCache = [String: SnappThemingToken<SnappThemingToggleStyleRepresentation>]()
    var animationCache = [String: SnappThemingToken<SnappThemingAnimationRepresentation>]()
}
