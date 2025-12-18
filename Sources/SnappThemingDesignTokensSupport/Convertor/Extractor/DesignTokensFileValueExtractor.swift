//
//  DesignTokensFileValueExtractor.swift
//
//  Created by Volodymyr Voiko on 15.04.2025.
//

import Foundation
import SnappDesignTokens
import SnappTheming
import UniformTypeIdentifiers

enum DesignTokensFileValueExtractorError: Error, Equatable {
    case unknownFileType(URL)
    case unsupportedFileType(URL, UTType)
}

extension DesignTokensTokenValueExtractor {
    static var file: Self {
        .init {
            (
                fileValue: FileValue,
                key: String,
                caches: inout SnappThemingDeclarationCaches
            ) in
            let data = try Data(contentsOf: fileValue.url)
            let base64EncodedString = data.base64EncodedString(
                options: .endLineWithLineFeed
            )

            guard
                let contentType = UTType(
                    filenameExtension: fileValue.url.pathExtension
                )
            else {
                throw DesignTokensFileValueExtractorError.unknownFileType(
                    fileValue.url
                )
            }

            switch (
                true,
                contentType.preferredMIMEType,
                contentType.preferredFilenameExtension
            ) {
            case (
                contentType.conforms(to: .image),
                .some(let mimeType),
                _
            ):
                caches.imageCache[key] = .value(
                    "\(mimeType):base64:\(base64EncodedString)"
                )
            case (
                contentType.conforms(to: .font),
                _,
                _
            ):
                #warning("TODO: Properly retrieve font postscript name")
                caches.fontsCache[key] = .value(
                    SnappThemingFontInformation(
                        postScriptName: fileValue.url
                            .deletingPathExtension()
                            .lastPathComponent,
                        source: SnappThemingDataURI(
                            type: contentType,
                            encoding: .base64,
                            data: data
                        )
                    )
                )

            case (_, _, .lottiePathExtension),
                (_, _, .lotPathExtension):
                caches.animationCache[key] = .value(
                    SnappThemingAnimationRepresentation(
                        animation: .lottie(data)
                    )
                )
            case (_, _, _):
                throw DesignTokensFileValueExtractorError.unsupportedFileType(
                    fileValue.url,
                    contentType
                )
            }
        }
    }
}
