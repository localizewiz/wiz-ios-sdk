//
//  ObserverToken.swift
//  LocalizeWiz
//
//  Created by John Warmann on 2020-06-10.
//  Copyright © 2020 LocalizeWiz. All rights reserved.
//

import Foundation

public class ObserverToken: CustomStringConvertible {

    private let removalClosure: () -> Void
    private let identifier = UUID()

    init(removalBlock: @escaping () -> Void) {
        self.removalClosure = removalBlock
    }

    public func deregister() {
        removalClosure()
    }

    public var description: String {
        return "ObserverToken(\(self.identifier))"
    }
}
