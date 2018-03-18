//
//  Category.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 3/18/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

class Category: Selectable {
    let children: [Selectable]
    
    init(server_id: String, title: String, children: [Selectable]) {
        self.children = children
        super.init(server_id: server_id, title: title)
    }
}
