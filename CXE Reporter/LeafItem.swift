//
//  LeafItem.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 3/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

class LeafItem: Selectable {
    enum ControlType {
        case notListed
        case none
    }
    var controlType = ControlType.none
    
    func update(from leafItem: LeafItem) {
        super.update(from: leafItem)
        self.controlType = leafItem.controlType
    }
}

extension LeafItem: HasToBeProvidedByTheUser {
    var isProvided: Bool {
        if (self.controlType == .none) {
            return (
                (self.server_id != "") &&
                    (self.title != "")
            )
        } else if (self.controlType == .notListed) {
            return (self.title != "")
        }
        return false
    }
    var notProvidedFields: [String] {
        return []
    }
}
