//===----------------------------------------------------------------------===//
//
// This source file is part of the SwiftNIO open source project
//
// Copyright (c) 2020 Apple Inc. and the SwiftNIO project authors
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of SwiftNIO project authors
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//

import struct NIO.ByteBuffer

extension BodyStructure {
    /// IMAPv4 `body-type-mpart`
    public struct Multipart: Equatable {
        public var bodies: [BodyStructure]
        public var mediaSubtype: String
        public var multipartExtension: Extension?

        /// Convenience function for a better experience when chaining multiple types.
        public static func bodies(_ bodies: [BodyStructure], mediaSubtype: String, multipartExtension: Extension?) -> Self {
            Self(bodies: bodies, mediaSubtype: mediaSubtype, multipartExtension: multipartExtension)
        }
    }
}

extension BodyStructure.Multipart {
    /// IMAPv4 `body-ext-multipart`
    public struct Extension: Equatable {
        public var parameter: [FieldParameterPair]
        public var dspLanguage: BodyStructure.FieldDSPLanguage?

        /// Convenience function for a better experience when chaining multiple types.
        public static func parameter(_ parameters: [FieldParameterPair], dspLanguage: BodyStructure.FieldDSPLanguage?) -> Self {
            Self(parameter: parameters, dspLanguage: dspLanguage)
        }
    }
}

// MARK: - Encoding

extension ByteBuffer {
    @discardableResult mutating func writeBodyTypeMultipart(_ part: BodyStructure.Multipart) -> Int {
        part.bodies.reduce(into: 0) { (result, body) in
            result += self.writeBody(body)
        } +
            self.writeSpace() +
            self.writeIMAPString(part.mediaSubtype) +
            self.writeIfExists(part.multipartExtension) { (ext) -> Int in
                self.writeSpace() +
                    self.writeBodyExtensionMultipart(ext)
            }
    }

    @discardableResult mutating func writeBodyExtensionMultipart(_ ext: BodyStructure.Multipart.Extension) -> Int {
        self.writeBodyFieldParameters(ext.parameter) +
            self.writeIfExists(ext.dspLanguage) { (dspLanguage) -> Int in
                self.writeBodyFieldDSPLanguage(dspLanguage)
            }
    }
}