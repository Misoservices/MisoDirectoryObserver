//
//  FileChangesSource.swift
//  MisoDirectoryObserver
//
//  Created by Michel Donais on 2019-08-03.
//  Copyright © 2019-2020 Misoservices Inc. All rights reserved.
//  [BSL-1.0] This package is Licensed under the Boost Software License - Version 1.0
//

import Foundation

public class FileChangesSource {
    public struct FileError: Error {
        let message: String

        init(_ message: String) {
            self.message = message
        }

        public var localizedDescription: String {
            return message
        }
    }

    private let source: DispatchSourceProtocol
    private let fd: CInt
    public var activated = false {
        willSet {
            if newValue != self.activated {
                if newValue {
                    self.source.resume()
                } else {
                    self.source.suspend()
                }
            }
        }
    }

    public init(_ url: URL,
                activate: Bool = true,
                queue: DispatchQueue = DispatchQueue.main,
                callback: @escaping (_ url: URL)->Void) throws {
        
        self.fd = open(url.path, O_EVTONLY)
        if self.fd < 0 {
            throw FileError("Could not open \(url.path)")
        }
        self.source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: self.fd, eventMask: .all, queue: queue)
        self.source.setEventHandler {
            callback(url)
        }
        
        self.activated = activate
    }

    deinit {
        self.source.cancel()
        close(fd)
    }
}
