//
//  Selectable.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 3/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

class Selectable: NSObject {
    var server_id: String
    var title: String
    
    init(server_id: String, title: String) {
        self.server_id = server_id
        self.title = title
    }
    
    var json: [String: String] {
        return [
            "server_id": self.server_id,
            "title": self.title,
        ]
    }
    
    func update(from selectable: Selectable) {
        self.server_id = selectable.server_id
        self.title = selectable.title
    }
}

extension Sequence where Iterator.Element == Selectable {
    var categories: [Category] {
        var cs = [Category]()
        for selectable in self {
            if let category = selectable as? Category {
                cs.append(category)
            }
        }
        return cs
    }
    var leafItems: [LeafItem] {
        var ls = [LeafItem]()
        for selectable in self {
            if let leafItem = selectable as? LeafItem {
                ls.append(leafItem)
            }
        }
        return ls
    }
}

extension Dictionary {
    mutating func add(other: Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
}
