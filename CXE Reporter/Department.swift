//
//  Department.swift
//  CXE Reporter
//
//  Created by Muhammad Ali on 2/23/18.
//  Copyright © 2018 Customer Experience EcoSystem. All rights reserved.
//

import Foundation

class Department: LeafItem {
    static let SampleData: [Selectable] = [
            Category(server_id: "c1", title: "Maintenance", children: [
                Category(server_id: "c11", title: "Public Area", children: [
                    Department(server_id: "i111", title: "Rest Room Management"),
                    ]),
                Department(server_id: "i11", title: "Private Area"),
                ]),
            Department(server_id: "i1", title: "Custodial"),
        ]
}
