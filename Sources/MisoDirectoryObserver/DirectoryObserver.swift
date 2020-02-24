//
//  DirectoryObserver.swift
//  MisoDirectoryObserver
//
//  Created by Michel Donais on 2019-06-22.
//  Copyright © 2019-2020 Misoservices Inc. All rights reserved.
//  [BSL-1.0] This package is Licensed under the Boost Software License - Version 1.0
//

import Foundation
import Combine

public class DirectoryObserver: ObservableObject {
    public var source: FileChangesSource? = nil

    public init() {}
    
    public init?(_ url: URL,
                activate: Bool = true) {
        self.open(url, activate: activate)
    }
    
    public func open(_ url: URL,
                     activate: Bool = true) {
        self.source = try? FileChangesSource(url,
                                        activate: activate) { (_: URL) in
            self.objectWillChange.send()
        }
    }
    
    public func close() {
        self.source = nil
    }
    
    public func resume() {
        if let source = self.source {
            source.activated = true
            self.objectWillChange.send()
        }
    }

    public func suspend() {
        self.source?.activated = false
    }
}
