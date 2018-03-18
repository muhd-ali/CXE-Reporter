//
//  ProblemType.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/25/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

class ProblemType: LeafItem {
    static let SampleData: [Selectable] = [
        Category(server_id: "c1", title: "Electrical", children: [
            Category(server_id: "c11", title: "Airport Logistics", children: [
                ProblemType(server_id: "i111", title: "Plane Connector not working"),
                ]),
            ProblemType(server_id: "i11", title: "ATM Broken"),
            ]),
        ProblemType(server_id: "i1", title: "Spill"),
        ]
}
