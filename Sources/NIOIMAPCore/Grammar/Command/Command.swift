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

extension NIOIMAP {

    /// IMAP4 `command` (`command-any`, `command-auth`, `command-nonauth`, `command-select`)
    public struct Command: Equatable {
        public var type: CommandType
        public var tag: String

        public init(_ tag: String, _ type: CommandType) {
            self.type = type
            self.tag = tag
        }
    }

}

extension ByteBuffer {

    @discardableResult public mutating func writeCommand(_ command: NIOIMAP.Command) -> Int {
        var size = 0
        size += self.writeString("\(command.tag) ")
        size += self.writeCommandType(command.type)
        
        switch command.type {
        case .append(to: _, firstMessageMetadata: _):
            break
        default:
            size += self.writeString("\r\n")
        }
        return size
    }

}